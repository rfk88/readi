import { google, calendar_v3 } from 'googleapis';
import { prisma } from '../lib/prisma.js';
import { authService } from './auth.service.js';

export class GoogleCalendarService {
  /**
   * Get calendar client for user
   */
  private async getCalendarClient(userId: string) {
    const accessToken = await authService.getValidAccessToken(userId);
    
    const oauth2Client = new google.auth.OAuth2();
    oauth2Client.setCredentials({ access_token: accessToken });
    
    return google.calendar({ version: 'v3', auth: oauth2Client });
  }

  /**
   * Sync user's calendar events
   */
  async syncCalendarEvents(userId: string, timeMin?: Date, timeMax?: Date) {
    const calendar = await this.getCalendarClient(userId);

    const now = new Date();
    const startDate = timeMin || now;
    const endDate = timeMax || new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 days

    try {
      const response = await calendar.events.list({
        calendarId: 'primary',
        timeMin: startDate.toISOString(),
        timeMax: endDate.toISOString(),
        singleEvents: true,
        orderBy: 'startTime',
        maxResults: 250,
      });

      const events = response.data.items || [];
      
      // Process and store events
      for (const event of events) {
        await this.storeCalendarEvent(userId, event);
      }

      return {
        synced: events.length,
        timeRange: {
          start: startDate,
          end: endDate,
        },
      };
    } catch (error) {
      throw new Error(`Failed to sync calendar: ${(error as Error).message}`);
    }
  }

  /**
   * Store or update a calendar event
   */
  private async storeCalendarEvent(userId: string, event: calendar_v3.Schema$Event) {
    if (!event.id || !event.start || !event.summary) {
      return; // Skip events without required fields
    }

    const startTime = event.start.dateTime || event.start.date;
    const endTime = event.end?.dateTime || event.end?.date;

    if (!startTime || !endTime) {
      return;
    }

    // Store the event
    const storedEvent = await prisma.calendarEvent.upsert({
      where: {
        userId_googleEventId: {
          userId,
          googleEventId: event.id,
        },
      },
      update: {
        title: event.summary,
        description: event.description || null,
        startTime: new Date(startTime),
        endTime: new Date(endTime),
        location: event.location || null,
        meetingLink: event.hangoutLink || this.extractMeetingLink(event.description) || null,
        status: event.status || 'confirmed',
      },
      create: {
        userId,
        googleEventId: event.id,
        title: event.summary,
        description: event.description || null,
        startTime: new Date(startTime),
        endTime: new Date(endTime),
        location: event.location || null,
        meetingLink: event.hangoutLink || this.extractMeetingLink(event.description) || null,
        status: event.status || 'confirmed',
      },
    });

    // Store participants
    if (event.attendees && event.attendees.length > 0) {
      for (const attendee of event.attendees) {
        if (attendee.email) {
          await prisma.meetingParticipant.upsert({
            where: {
              eventId_email: {
                eventId: storedEvent.id,
                email: attendee.email,
              },
            },
            update: {
              name: attendee.displayName || null,
              isOrganizer: attendee.organizer || false,
              responseStatus: attendee.responseStatus || null,
            },
            create: {
              eventId: storedEvent.id,
              email: attendee.email,
              name: attendee.displayName || null,
              isOrganizer: attendee.organizer || false,
              responseStatus: attendee.responseStatus || null,
            },
          });
        }
      }
    }

    // Store organizer if not in attendees
    if (event.organizer?.email) {
      await prisma.meetingParticipant.upsert({
        where: {
          eventId_email: {
            eventId: storedEvent.id,
            email: event.organizer.email,
          },
        },
        update: {
          name: event.organizer.displayName || null,
          isOrganizer: true,
        },
        create: {
          eventId: storedEvent.id,
          email: event.organizer.email,
          name: event.organizer.displayName || null,
          isOrganizer: true,
        },
      });
    }

    return storedEvent;
  }

  /**
   * Extract meeting link from description
   */
  private extractMeetingLink(description?: string | null): string | null {
    if (!description) return null;

    // Common meeting link patterns
    const patterns = [
      /https?:\/\/meet\.google\.com\/[a-z-]+/i,
      /https?:\/\/zoom\.us\/j\/\d+/i,
      /https?:\/\/teams\.microsoft\.com\/l\/meetup-join\/[^\s]+/i,
    ];

    for (const pattern of patterns) {
      const match = description.match(pattern);
      if (match) {
        return match[0];
      }
    }

    return null;
  }

  /**
   * Get upcoming meetings for user
   */
  async getUpcomingMeetings(userId: string, limit = 20) {
    const now = new Date();

    const meetings = await prisma.calendarEvent.findMany({
      where: {
        userId,
        startTime: {
          gte: now,
        },
        status: 'confirmed',
      },
      include: {
        participants: true,
        talkingPoints: {
          select: {
            id: true,
            generatedAt: true,
            feedback: true,
          },
        },
      },
      orderBy: {
        startTime: 'asc',
      },
      take: limit,
    });

    return meetings;
  }

  /**
   * Get meeting by ID
   */
  async getMeetingById(userId: string, meetingId: string) {
    const meeting = await prisma.calendarEvent.findFirst({
      where: {
        id: meetingId,
        userId,
      },
      include: {
        participants: true,
        talkingPoints: true,
        emailLinks: {
          include: {
            thread: {
              include: {
                messages: {
                  orderBy: {
                    date: 'desc',
                  },
                  take: 5,
                },
              },
            },
          },
        },
      },
    });

    return meeting;
  }

  /**
   * Set up calendar webhook (Google Calendar push notifications)
   */
  async setupWebhook(userId: string, webhookUrl: string) {
    const calendar = await this.getCalendarClient(userId);

    try {
      const response = await calendar.events.watch({
        calendarId: 'primary',
        requestBody: {
          id: `readi-${userId}`,
          type: 'web_hook',
          address: webhookUrl,
        },
      });

      return {
        channelId: response.data.id,
        resourceId: response.data.resourceId,
        expiration: response.data.expiration,
      };
    } catch (error) {
      throw new Error(`Failed to setup webhook: ${(error as Error).message}`);
    }
  }
}

export const googleCalendarService = new GoogleCalendarService();

