import Fastify from 'fastify';
import type { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import { healthRoute } from './routes/health.js';
import { authRoutes } from './routes/auth.js';
import { profileRoutes } from './routes/profiles.js';
import { meetingRoutes } from './routes/meetings.js';
import { emailRoutes } from './routes/emails.js';
import { authenticate } from './middleware/auth.js';
import { prisma } from './lib/prisma.js';
import { env } from './config/env.js';

export function createServer(): FastifyInstance {
  const app = Fastify({
    logger: {
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug'
    }
  });

  // Register CORS
  app.register(cors, {
    origin: [env.WEB_URL, env.IOS_APP_SCHEME],
    credentials: true,
  });

  // Register JWT
  app.register(jwt, {
    secret: env.JWT_SECRET,
  });

  // Add Prisma to app context
  app.decorate('prisma', prisma);

  // Add authenticate decorator
  app.decorate('authenticate', authenticate);

  // Register routes
  app.register(healthRoute, { prefix: '/health' });
  app.register(authRoutes, { prefix: '/api/v1/auth' });
  app.register(profileRoutes, { prefix: '/api/v1/profiles' });
  app.register(meetingRoutes, { prefix: '/api/v1/meetings' });
  app.register(emailRoutes, { prefix: '/api/v1/emails' });

  return app;
}
