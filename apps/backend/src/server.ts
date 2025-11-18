import Fastify from 'fastify';
import type { FastifyInstance } from 'fastify';
import { healthRoute } from './routes/health.js';

export function createServer(): FastifyInstance {
  const app = Fastify({
    logger: {
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug'
    }
  });

  app.register(healthRoute, { prefix: '/health' });

  return app;
}
