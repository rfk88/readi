import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { gmailService } from '../services/gmail.service.js';

const syncQuerySchema = z.object({
  maxResults: z.coerce.number().int().positive().max(500).optional(),
});

const participantQuerySchema = z.object({
  email: z.string().email(),
});

export async function emailRoutes(app: FastifyInstance) {
  /**
   * POST /emails/sync
   * Sync emails from Gmail
   */
  app.post('/sync', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const query = syncQuerySchema.parse(request.query);

      const result = await gmailService.syncEmails(userId, query.maxResults);

      return {
        message: 'Emails synced successfully',
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

      app.log.error(error, 'Email sync failed');
      return reply.code(500).send({
        error: {
          code: 'SYNC_ERROR',
          message: 'Failed to sync emails',
          details: (error as Error).message,
        },
      });
    }
  });

  /**
   * GET /emails/threads
   * Get email threads
   */
  app.get('/threads', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { limit } = request.query as { limit?: string };

      const threads = await app.prisma.emailThread.findMany({
        where: { userId },
        include: {
          messages: {
            orderBy: { date: 'desc' },
            take: 1,
          },
        },
        orderBy: {
          lastMessageDate: 'desc',
        },
        take: limit ? parseInt(limit) : 50,
      });

      return {
        threads,
        count: threads.length,
      };
    } catch (error) {
      app.log.error(error, 'Failed to fetch threads');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch email threads',
        },
      });
    }
  });

  /**
   * GET /emails/threads/:id
   * Get email thread details
   */
  app.get('/threads/:id', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { id } = request.params as { id: string };

      const thread = await app.prisma.emailThread.findFirst({
        where: { id, userId },
        include: {
          messages: {
            orderBy: { date: 'asc' },
          },
        },
      });

      if (!thread) {
        return reply.code(404).send({
          error: {
            code: 'THREAD_NOT_FOUND',
            message: 'Email thread not found',
          },
        });
      }

      return { thread };
    } catch (error) {
      app.log.error(error, 'Failed to fetch thread');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch email thread',
        },
      });
    }
  });

  /**
   * GET /emails/by-participant
   * Find emails by participant
   */
  app.get('/by-participant', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const query = participantQuerySchema.parse(request.query);

      const threads = await gmailService.findThreadsByParticipant(userId, query.email);

      return {
        threads,
        count: threads.length,
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

      app.log.error(error, 'Failed to find threads');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to find email threads',
        },
      });
    }
  });

  /**
   * POST /emails/link-to-meeting/:meetingId
   * Link emails to a meeting
   */
  app.post('/link-to-meeting/:meetingId', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const { meetingId } = request.params as { meetingId: string };

      await gmailService.linkEmailsToMeeting(userId, meetingId);

      return {
        message: 'Emails linked to meeting successfully',
      };
    } catch (error) {
      app.log.error(error, 'Failed to link emails');
      return reply.code(500).send({
        error: {
          code: 'LINK_ERROR',
          message: 'Failed to link emails to meeting',
          details: (error as Error).message,
        },
      });
    }
  });
}

