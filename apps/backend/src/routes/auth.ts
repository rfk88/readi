import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authService } from '../services/auth.service.js';
import { env } from '../config/env.js';

const callbackQuerySchema = z.object({
  code: z.string(),
  state: z.string().optional(),
});

export async function authRoutes(app: FastifyInstance) {
  /**
   * GET /auth/google
   * Initiate Google OAuth flow
   */
  app.get('/google', async (request, reply) => {
    try {
      const authUrl = authService.getAuthorizationUrl();
      return reply.redirect(authUrl);
    } catch (error) {
      app.log.error(error, 'Failed to generate auth URL');
      return reply.code(500).send({
        error: {
          code: 'AUTH_ERROR',
          message: 'Failed to initiate authentication',
        },
      });
    }
  });

  /**
   * GET /auth/google/callback
   * Handle Google OAuth callback
   */
  app.get('/google/callback', async (request, reply) => {
    try {
      const query = callbackQuerySchema.parse(request.query);

      // Exchange code for tokens
      const tokens = await authService.getTokensFromCode(query.code);

      // Get user info from Google
      const userInfo = await authService.getUserInfo(tokens.access_token);

      // Create or update user
      const user = await authService.upsertUser(userInfo, tokens);

      // Generate JWT
      const token = await reply.jwtSign({
        userId: user.id,
        email: user.email,
      }, {
        expiresIn: env.JWT_EXPIRES_IN,
      });

      // For mobile: use custom scheme (ASWebAuthenticationSession handles this)
      // Check if request is from ASWebAuthenticationSession (simulator or device)
      const userAgent = request.headers['user-agent'] || '';
      const isMobile = userAgent.includes('Mobile') || userAgent.includes('iPhone') || userAgent.includes('iPad');
      
      if (isMobile) {
        // Redirect to iOS app via custom URL scheme
        return reply.redirect(`${env.IOS_APP_SCHEME}auth/callback?token=${token}`);
      } else {
        // Web fallback
        return reply.redirect(`${env.WEB_URL}/auth/callback?token=${token}`);
      }
    } catch (error) {
      app.log.error(error, 'OAuth callback error');
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      const errorStack = error instanceof Error ? error.stack : undefined;
      
      // Log full error details
      console.error('=== OAUTH CALLBACK ERROR ===');
      console.error('Error:', errorMessage);
      console.error('Stack:', errorStack);
      console.error('Request query:', request.query);
      console.error('===========================');
      
      // Always redirect for mobile (ASWebAuthenticationSession needs a redirect)
      // Never return JSON error for mobile - it breaks ASWebAuthenticationSession
      const userAgent = request.headers['user-agent'] || '';
      const isMobile = userAgent.includes('Mobile') || userAgent.includes('iPhone') || userAgent.includes('iPad') || userAgent.includes('Simulator');
      
      if (isMobile) {
        // Always redirect to app (even on error) - ASWebAuthenticationSession requires this
        // App will handle the error parameter
        return reply.redirect(`${env.IOS_APP_SCHEME}auth/callback?error=${encodeURIComponent(errorMessage)}`);
      } else {
        // Web can handle JSON errors
        return reply.code(400).send({
          error: {
            code: 'OAUTH_ERROR',
            message: 'Failed to complete authentication',
            details: errorMessage,
          },
        });
      }
    }
  });

  /**
   * POST /auth/refresh
   * Refresh JWT token
   */
  app.post('/refresh', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId, email } = request.user as { userId: string; email: string };

      const newToken = await reply.jwtSign({
        userId,
        email,
      }, {
        expiresIn: env.JWT_EXPIRES_IN,
      });

      return {
        token: newToken,
      };
    } catch (error) {
      app.log.error(error, 'Token refresh error');
      return reply.code(401).send({
        error: {
          code: 'REFRESH_ERROR',
          message: 'Failed to refresh token',
        },
      });
    }
  });

  /**
   * POST /auth/logout
   * Logout user (invalidate token on client side)
   */
  app.post('/logout', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    // In a production app, you might want to blacklist the token
    // For now, client-side token deletion is sufficient
    return {
      message: 'Logged out successfully',
    };
  });

  /**
   * GET /auth/me
   * Get current user info
   */
  app.get('/me', {
    onRequest: [app.authenticate],
  }, async (request, reply) => {
    try {
      const { userId } = request.user as { userId: string };

      const user = await app.prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          email: true,
          name: true,
          createdAt: true,
          profile: {
            select: {
              role: true,
              displayName: true,
              timeZone: true,
              reminderMinutes: true,
              resumeUrl: true,
              jobRole: true,
              targetCompanies: true,
              companyName: true,
              productDescription: true,
              salesPainPoints: true,
              salesTargets: true,
              preferredMeetingTypes: true,
              notificationPreference: true,
              notes: true,
            },
          },
        },
      });

      if (!user) {
        return reply.code(404).send({
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found',
          },
        });
      }

      return { user };
    } catch (error) {
      app.log.error(error, 'Failed to fetch user');
      return reply.code(500).send({
        error: {
          code: 'FETCH_ERROR',
          message: 'Failed to fetch user information',
        },
      });
    }
  });
}

