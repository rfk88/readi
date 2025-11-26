import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { profileService } from '../services/profile.service.js';

const profileSchema = z.object({
  name: z.string().optional(),
  role: z.enum(['job_seeker', 'sales']),
  displayName: z.string().optional(),
  timeZone: z.string().optional(),
  reminderMinutes: z.number().int().positive().optional(),
  resumeUrl: z.string().url().optional(),
  jobRole: z.string().optional(),
  targetCompanies: z.array(z.string()).optional(),
  companyName: z.string().optional(),
  productDescription: z.string().optional(),
  salesPainPoints: z.string().optional(),
  salesTargets: z.string().optional(),
  preferredMeetingTypes: z.array(z.string()).optional(),
  notificationPreference: z.enum(['push', 'email', 'both']).optional(),
  notes: z.string().optional(),
  profileData: z.record(z.any()).optional(),
});

export async function profileRoutes(app: FastifyInstance) {
  /**
   * GET /profiles/me
   * Get current user's profile
   */
  app.get('/me', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };

      const profile = await profileService.getProfile(userId);

      if (!profile) {
        return reply.code(404).send({
          error: {
            code: 'PROFILE_NOT_FOUND',
            message: 'Profile not found',
          },
        });
      }

      return { profile };
    } catch (error) {
      app.log.error(error, 'Failed to fetch profile');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch profile',
        },
      });
    }
  });

  /**
   * POST /profiles
   * Create or update profile
   */
  app.post('/', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      app.log.info({ userId, body: request.body }, 'Creating/updating profile');
      
      const data = profileSchema.parse(request.body);
      app.log.info({ userId, data }, 'Profile data validated');

      const validationError = validateProfilePayload(data);
      if (validationError) {
        app.log.warn({ userId, validationError, data }, 'Profile validation failed');
        return reply.code(400).send({
          error: {
            code: 'VALIDATION_ERROR',
            message: validationError,
          },
        });
      }

      const profile = await profileService.upsertProfile(userId, {
        ...data,
        reminderMinutes: data.reminderMinutes ?? 30,
      });

      app.log.info({ userId, profileId: profile.id }, 'Profile saved successfully');
      return { profile };
    } catch (error) {
      if (error instanceof z.ZodError) {
        app.log.warn({ userId, errors: error.errors, body: request.body }, 'Profile schema validation failed');
        return reply.code(400).send({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid profile data',
            details: error.errors,
          },
        });
      }

      app.log.error({ userId, error, body: request.body }, 'Failed to create/update profile');
      return reply.code(500).send({
        error: {
          code: 'SAVE_ERROR',
          message: 'Failed to save profile',
          details: (error as Error).message,
        },
      });
    }
  });

  /**
   * PUT /profiles
   * Update profile (alias for POST)
   */
  app.put('/', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };
      const data = profileSchema.partial().parse(request.body);

      // Get existing profile
      const existingProfile = await profileService.getProfile(userId);

      if (!existingProfile) {
        return reply.code(404).send({
          error: {
            code: 'PROFILE_NOT_FOUND',
            message: 'Profile not found. Create one first.',
          },
        });
      }

      // Merge with existing data
      const updatedData = {
        name: data.name ?? undefined,
        role: data.role || existingProfile.role,
        displayName: data.displayName ?? existingProfile.displayName ?? undefined,
        timeZone: data.timeZone ?? existingProfile.timeZone ?? undefined,
        reminderMinutes: data.reminderMinutes ?? existingProfile.reminderMinutes ?? 30,
        resumeUrl: data.resumeUrl ?? existingProfile.resumeUrl,
        jobRole: data.jobRole ?? existingProfile.jobRole,
        targetCompanies: data.targetCompanies ?? existingProfile.targetCompanies ?? undefined,
        companyName: data.companyName ?? existingProfile.companyName,
        productDescription: data.productDescription ?? existingProfile.productDescription,
        salesPainPoints: data.salesPainPoints ?? existingProfile.salesPainPoints ?? undefined,
        salesTargets: data.salesTargets ?? existingProfile.salesTargets ?? undefined,
        preferredMeetingTypes:
          data.preferredMeetingTypes ?? existingProfile.preferredMeetingTypes ?? undefined,
        notificationPreference:
          data.notificationPreference ?? existingProfile.notificationPreference ?? undefined,
        notes: data.notes ?? existingProfile.notes ?? undefined,
        profileData: data.profileData ?? existingProfile.profileData,
      } as any;

      const profile = await profileService.upsertProfile(userId, updatedData);

      return { profile };
    } catch (error) {
      if (error instanceof z.ZodError) {
        return reply.code(400).send({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid profile data',
            details: error.errors,
          },
        });
      }

      app.log.error(error, 'Failed to update profile');
      return reply.code(500).send({
        error: {
          code: 'UPDATE_ERROR',
          message: 'Failed to update profile',
        },
      });
    }
  });

  /**
   * DELETE /profiles
   * Delete profile
   */
  app.delete('/', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };

      await profileService.deleteProfile(userId);

      return {
        message: 'Profile deleted successfully',
      };
    } catch (error) {
      app.log.error(error, 'Failed to delete profile');
      return reply.code(500).send({
        error: {
          code: 'DELETE_ERROR',
          message: 'Failed to delete profile',
        },
      });
    }
  });

  /**
   * POST /profiles/resume
   * Upload resume (placeholder - implement file upload later)
   */
  app.post('/resume', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    // TODO: Implement file upload with @fastify/multipart
    return reply.code(501).send({
      error: {
        code: 'NOT_IMPLEMENTED',
        message: 'Resume upload not yet implemented',
      },
    });
  });
}

function validateProfilePayload(data: z.infer<typeof profileSchema>): string | null {
  if (data.role === 'job_seeker') {
    if (!data.jobRole?.trim()) {
      return 'Job seekers must provide a target role.';
    }
    if (!data.targetCompanies || data.targetCompanies.length === 0) {
      return 'Add at least one target company.';
    }
  }

  if (data.role === 'sales') {
    if (!data.companyName?.trim()) {
      return 'Sales professionals must provide their company name.';
    }
    if (!data.productDescription?.trim()) {
      return 'Add a short product description.';
    }
  }

  return null;
}

