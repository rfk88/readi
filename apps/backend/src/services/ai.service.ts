import { env } from '../config/env.js';
import { prisma } from '../lib/prisma.js';

type TalkingPointPayload = {
  id: string;
  meetingId: string;
  points: string[];
  aiModel: string;
  generatedAt: Date;
  feedback?: string | null;
  citations?: unknown;
};

class AIService {
  private model = 'gpt-4o-mini';

  async generateTalkingPoints(userId: string, meetingId: string): Promise<TalkingPointPayload> {
    const meeting = await prisma.calendarEvent.findFirst({
      where: { id: meetingId, userId },
      include: {
        participants: true,
        talkingPoints: true,
        user: {
          include: {
            profile: true,
          },
        },
        emailLinks: {
          include: {
            thread: {
              include: {
                messages: {
                  orderBy: { date: 'desc' },
                  take: 5,
                },
              },
            },
          },
        },
      },
    });

    if (!meeting) {
      throw new Error('Meeting not found');
    }

    const profile = meeting.user.profile;
    const emailSnippets = meeting.emailLinks.flatMap((link) =>
      link.thread.messages.map((message) => `${message.fromEmail}: ${message.bodyText ?? ''}`)
    );

    const prompt = this.buildPrompt({
      meeting,
      profile,
      emailSnippets,
    });

    const points = env.OPENAI_API_KEY
      ? await this.callOpenAI(prompt)
      : this.mockTalkingPoints(meeting.title);

    const record = await prisma.talkingPoint.upsert({
      where: { meetingId },
      update: {
        points,
        aiModel: this.model,
        generatedAt: new Date(),
      },
      create: {
        meetingId,
        userId,
        points,
        aiModel: this.model,
      },
    });

    return {
      id: record.id,
      meetingId: record.meetingId,
      points: record.points as string[],
      aiModel: record.aiModel,
      generatedAt: record.generatedAt,
      feedback: record.feedback,
      citations: record.citations,
    };
  }

  async getTalkingPoints(userId: string, meetingId: string): Promise<TalkingPointPayload | null> {
    const record = await prisma.talkingPoint.findFirst({
      where: { meetingId, userId },
    });

    if (!record) {
      return null;
    }

    return {
      id: record.id,
      meetingId: record.meetingId,
      points: record.points as string[],
      aiModel: record.aiModel,
      generatedAt: record.generatedAt,
      feedback: record.feedback,
      citations: record.citations,
    };
  }

  async submitFeedback(userId: string, meetingId: string, feedback?: string, notes?: string) {
    await prisma.talkingPoint.updateMany({
      where: { meetingId, userId },
      data: {
        feedback,
        citations: notes ? { notes } : undefined,
      },
    });
  }

  private buildPrompt({
    meeting,
    profile,
    emailSnippets,
  }: {
    meeting: any;
    profile: any;
    emailSnippets: string[];
  }) {
    const roleLabel = profile?.role === 'sales' ? 'sales professional' : 'job seeker';
    const profileContext = [
      profile?.displayName ? `Preferred name: ${profile.displayName}` : null,
      profile?.jobRole ? `Job role: ${profile.jobRole}` : null,
      profile?.targetCompany ? `Target company: ${profile.targetCompany}` : null,
      profile?.companyName ? `Company: ${profile.companyName}` : null,
      profile?.productDescription ? `Product: ${profile.productDescription}` : null,
      profile?.notes ? `Notes: ${profile.notes}` : null,
    ]
      .filter(Boolean)
      .join('\n');

    const participantList = meeting.participants
      .map((p: any) => `${p.name ?? p.email}${p.isOrganizer ? ' (organizer)' : ''}`)
      .join(', ');

    const emailContext = emailSnippets.slice(0, 5).join('\n');

    return `
You are Readi, an assistant that prepares a ${roleLabel} for meetings.

Meeting: ${meeting.title}
When: ${meeting.startTime.toISOString()}
Participants: ${participantList || 'Not provided'}

User Profile:
${profileContext || 'No extra profile info'}

Recent Emails:
${emailContext || 'No recent emails found'}

Generate 3-4 short talking points (bulleted) that help the user make a strong impression. Keep language crisp and actionable.
    `.trim();
  }

  private async callOpenAI(prompt: string): Promise<string[]> {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: this.model,
        temperature: 0.4,
        messages: [
          {
            role: 'system',
            content: 'You create concise meeting prep talking points.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI error: ${response.status} ${await response.text()}`);
    }

    const data = await response.json();
    const content: string = data.choices?.[0]?.message?.content ?? '';
    return this.parseBulletPoints(content);
  }

  private parseBulletPoints(content: string): string[] {
    if (!content) return [];
    const lines = content
      .split('\n')
      .map((line: string) => line.replace(/^[\-\d\.\s]+/, '').trim())
      .filter((line: string) => line.length > 0);

    return lines.length ? lines : [content];
  }

  private mockTalkingPoints(title: string): string[] {
    return [
      `Open the meeting by acknowledging "${title}" and restating the desired outcome.`,
      'Share one relevant story or win that proves your value.',
      'Ask a clarifying question that keeps the conversation focused on next steps.',
    ];
  }
}

export const aiService = new AIService();

