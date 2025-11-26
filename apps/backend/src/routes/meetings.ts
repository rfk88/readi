import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { googleCalendarService } from '../services/googleCalendar.service.js';
import { aiService } from '../services/ai.service.js';

const syncQuerySchema = z.object({
  timeMin: z.string().datetime().optional(),
  timeMax: z.string().datetime().optional(),
});

export async function meetingRoutes(app: FastifyInstance) {
  /**
   * POST /meetings/sync
   * Sync calendar events from Google Calendar
   */
  app.post('/sync', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const query = syncQuerySchema.parse(request.query);

      const timeMin = query.timeMin ? new Date(query.timeMin) : undefined;
      const timeMax = query.timeMax ? new Date(query.timeMax) : undefined;

      const result = await googleCalendarService.syncCalendarEvents(userId, timeMin, timeMax);

      return {
        message: 'Calendar synced successfully',
        ...result,
      };
    } catch (error) {
      if (error instanceof z.ZodError) {
        return reply.code(400).send({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid query parameters',
            details: error.errors,
          },
        });
      }

      app.log.error(error, 'Calendar sync failed');
      return reply.code(500).send({
        error: {
          code: 'SYNC_ERROR',
          message: 'Failed to sync calendar',
          details: (error as Error).message,
        },
      });
    }
  });

  /**
   * GET /meetings/upcoming
   * Get upcoming meetings
   */
  app.get('/upcoming', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { limit } = request.query as { limit?: string };

      const meetings = await googleCalendarService.getUpcomingMeetings(
        userId,
        limit ? parseInt(limit) : 20
      );

      // Calculate time until meeting for each
      const now = new Date();
      const meetingsWithTime = meetings.map((meeting) => {
        const timeUntil = meeting.startTime.getTime() - now.getTime();
        const minutesUntil = Math.floor(timeUntil / (60 * 1000));
        const hoursUntil = Math.floor(minutesUntil / 60);

        return {
          ...meeting,
          minutesUntilStart: minutesUntil,
          hoursUntilStart: hoursUntil,
          isPrepReady: meeting.talkingPoints.length > 0,
        };
      });

      return {
        meetings: meetingsWithTime,
        count: meetingsWithTime.length,
      };
    } catch (error) {
      app.log.error(error, 'Failed to fetch upcoming meetings');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch upcoming meetings',
        },
      });
    }
  });

  /**
   * GET /meetings/:id
   * Get meeting details
   */
  app.get('/:id', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };

      const meeting = await googleCalendarService.getMeetingById(userId, id);

      if (!meeting) {
        return reply.code(404).send({
          error: {
            code: 'MEETING_NOT_FOUND',
            message: 'Meeting not found',
          },
        });
      }

      return { meeting };
    } catch (error) {
      app.log.error(error, 'Failed to fetch meeting');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch meeting details',
        },
      });
    }
  });

  /**
   * GET /meetings/:id/participants
   * Get meeting participants
   */
  app.get('/:id/participants', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };

      const meeting = await app.prisma.calendarEvent.findFirst({
        where: { id, userId },
        include: { participants: true },
      });

      if (!meeting) {
        return reply.code(404).send({
          error: {
            code: 'MEETING_NOT_FOUND',
            message: 'Meeting not found',
          },
        });
      }

      return {
        participants: meeting.participants,
      };
    } catch (error) {
      app.log.error(error, 'Failed to fetch participants');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch participants',
        },
      });
    }
  });

  /**
   * POST /meetings/webhook
   * Handle Google Calendar webhook notifications
   */
  app.post('/webhook', async (request, reply) => {
    try {
      // Google Calendar sends notifications for calendar changes
      const channelId = request.headers['x-goog-channel-id'];
      const resourceState = request.headers['x-goog-resource-state'];

      app.log.info({ channelId, resourceState }, 'Calendar webhook received');

      // In production, you would:
      // 1. Verify the webhook is from Google
      // 2. Extract user ID from channel ID
      // 3. Trigger calendar sync for that user

      // For now, just acknowledge receipt
      return reply.code(200).send({ received: true });
    } catch (error) {
      app.log.error(error, 'Webhook processing failed');
      return reply.code(500).send({
        error: {
          code: 'WEBHOOK_ERROR',
          message: 'Failed to process webhook',
        },
      });
    }
  });

  /**
   * POST /meetings/:id/generate-prep
   * Generate talking points for a meeting
   */
  app.post('/:id/generate-prep', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };

      const record = await aiService.generateTalkingPoints(userId, id);

      return {
        talkingPoints: record,
      };
    } catch (error) {
      app.log.error(error, 'Failed to generate talking points');
      return reply.code(500).send({
        error: {
          code: 'AI_ERROR',
          message: 'Failed to generate prep',
        },
      });
    }
  });

  /**
   * GET /meetings/:id/talking-points
   * Fetch talking points
   */
  app.get('/:id/talking-points', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };

      const record = await aiService.getTalkingPoints(userId, id);

      return {
        talkingPoints: record,
      };
    } catch (error) {
      app.log.error(error, 'Failed to fetch talking points');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch talking points',
        },
      });
    }
  });

  /**
   * POST /meetings/:id/feedback
   * Record feedback on prep quality
   */
  app.post('/:id/feedback', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    const bodySchema = z.object({
      feedback: z.enum(['helpful', 'not_helpful']).optional(),
      notes: z.string().optional(),
    });

    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };
      const body = bodySchema.parse(request.body ?? {});

      await aiService.submitFeedback(userId, id, body.feedback, body.notes);

      return { message: 'Feedback captured' };
    } catch (error) {
      if (error instanceof z.ZodError) {
        return reply.code(400).send({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid feedback payload',
            details: error.errors,
          },
        });
      }

      app.log.error(error, 'Failed to submit feedback');
      return reply.code(500).send({
        error: {
          code: 'FEEDBACK_ERROR',
          message: 'Failed to submit feedback',
        },
      });
    }
  });
}

