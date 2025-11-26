import { google, gmail_v1 } from 'googleapis';
import { prisma } from '../lib/prisma.js';
import { authService } from './auth.service.js';

export class GmailService {
  /**
   * Get Gmail client for user
   */
  private async getGmailClient(userId: string) {
    const accessToken = await authService.getValidAccessToken(userId);
    
    const oauth2Client = new google.auth.OAuth2();
    oauth2Client.setCredentials({ access_token: accessToken });
    
    return google.gmail({ version: 'v1', auth: oauth2Client });
  }

  /**
   * Sync emails for user
   */
  async syncEmails(userId: string, maxResults = 100) {
    const gmail = await this.getGmailClient(userId);

    try {
      // Get recent threads
      const response = await gmail.users.threads.list({
        userId: 'me',
        maxResults,
      });

      const threads = response.data.threads || [];
      
      for (const thread of threads) {
        if (thread.id) {
          await this.syncThread(userId, thread.id);
        }
      }

      return {
        synced: threads.length,
      };
    } catch (error) {
      throw new Error(`Failed to sync emails: ${(error as Error).message}`);
    }
  }

  /**
   * Sync a specific email thread
   */
  private async syncThread(userId: string, threadId: string) {
    const gmail = await this.getGmailClient(userId);

    try {
      const thread = await gmail.users.threads.get({
        userId: 'me',
        id: threadId,
        format: 'full',
      });

      const messages = thread.data.messages || [];
      if (messages.length === 0) return;

      // Extract thread info from first message
      const firstMessage = messages[0];
      const subject = this.getHeader(firstMessage.payload, 'Subject') || 'No Subject';
      
      // Get all participant emails
      const participantEmails = new Set<string>();
      messages.forEach((message) => {
        const from = this.getHeader(message.payload, 'From');
        const to = this.getHeader(message.payload, 'To');
        const cc = this.getHeader(message.payload, 'Cc');

        if (from) this.extractEmails(from).forEach((e) => participantEmails.add(e));
        if (to) this.extractEmails(to).forEach((e) => participantEmails.add(e));
        if (cc) this.extractEmails(cc).forEach((e) => participantEmails.add(e));
      });

      // Get last message date
      const lastMessage = messages[messages.length - 1];
      const lastMessageDate = new Date(parseInt(lastMessage.internalDate || '0'));

      // Store thread
      const storedThread = await prisma.emailThread.upsert({
        where: {
          userId_gmailThreadId: {
            userId,
            gmailThreadId: threadId,
          },
        },
        update: {
          subject,
          participantEmails: Array.from(participantEmails),
          lastMessageDate,
          messageCount: messages.length,
        },
        create: {
          userId,
          gmailThreadId: threadId,
          subject,
          participantEmails: Array.from(participantEmails),
          lastMessageDate,
          messageCount: messages.length,
        },
      });

      // Store messages
      for (const message of messages) {
        if (message.id) {
          await this.storeMessage(storedThread.id, message);
        }
      }

      return storedThread;
    } catch (error) {
      console.error(`Failed to sync thread ${threadId}:`, error);
      return null;
    }
  }

  /**
   * Store an email message
   */
  private async storeMessage(threadId: string, message: gmail_v1.Schema$Message) {
    const messageId = message.id!;
    const payload = message.payload!;

    const from = this.getHeader(payload, 'From') || '';
    const to = this.getHeader(payload, 'To') || '';
    const subject = this.getHeader(payload, 'Subject') || '';
    const date = new Date(parseInt(message.internalDate || '0'));

    const fromEmails = this.extractEmails(from);
    const toEmails = this.extractEmails(to);

    const bodyText = this.getMessageBody(payload, 'text/plain');
    const bodyHtml = this.getMessageBody(payload, 'text/html');

    await prisma.emailMessage.upsert({
      where: {
        gmailMessageId: messageId,
      },
      update: {
        fromEmail: fromEmails[0] || from,
        toEmails,
        subject,
        bodyText,
        bodyHtml,
        date,
      },
      create: {
        threadId,
        gmailMessageId: messageId,
        fromEmail: fromEmails[0] || from,
        toEmails,
        subject,
        bodyText,
        bodyHtml,
        date,
      },
    });
  }

  /**
   * Get email header value
   */
  private getHeader(payload: gmail_v1.Schema$MessagePart | null | undefined, name: string): string | null {
    if (!payload?.headers) return null;
    const header = payload.headers.find((h) => h.name?.toLowerCase() === name.toLowerCase());
    return header?.value || null;
  }

  /**
   * Extract email addresses from a string
   */
  private extractEmails(str: string): string[] {
    const emailRegex = /[\w.-]+@[\w.-]+\.\w+/g;
    return str.match(emailRegex) || [];
  }

  /**
   * Get message body by MIME type
   */
  private getMessageBody(payload: gmail_v1.Schema$MessagePart, mimeType: string): string | null {
    if (payload.mimeType === mimeType && payload.body?.data) {
      return Buffer.from(payload.body.data, 'base64').toString('utf-8');
    }

    if (payload.parts) {
      for (const part of payload.parts) {
        const body = this.getMessageBody(part, mimeType);
        if (body) return body;
      }
    }

    return null;
  }

  /**
   * Find email threads with a specific participant
   */
  async findThreadsByParticipant(userId: string, participantEmail: string) {
    const threads = await prisma.emailThread.findMany({
      where: {
        userId,
        participantEmails: {
          has: participantEmail.toLowerCase(),
        },
      },
      include: {
        messages: {
          orderBy: {
            date: 'desc',
          },
          take: 3, // Get last 3 messages
        },
      },
      orderBy: {
        lastMessageDate: 'desc',
      },
      take: 10,
    });

    return threads;
  }

  /**
   * Link emails to a meeting
   */
  async linkEmailsToMeeting(userId: string, meetingId: string) {
    // Get meeting participants
    const meeting = await prisma.calendarEvent.findFirst({
      where: { id: meetingId, userId },
      include: { participants: true },
    });

    if (!meeting) {
      throw new Error('Meeting not found');
    }

    // Find emails with any of the participants
    for (const participant of meeting.participants) {
      const threads = await this.findThreadsByParticipant(userId, participant.email);

      for (const thread of threads) {
        // Link thread to meeting
        await prisma.meetingEmailLink.upsert({
          where: {
            meetingId_threadId: {
              meetingId,
              threadId: thread.id,
            },
          },
          create: {
            meetingId,
            threadId: thread.id,
          },
          update: {},
        });
      }
    }
  }
}

export const gmailService = new GmailService();

