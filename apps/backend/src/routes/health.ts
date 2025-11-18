import type { FastifyInstance } from 'fastify';

export async function healthRoute(app: FastifyInstance) {
  app.get('/', async () => ({
    status: 'ok',
    service: 'readi-backend',
    timestamp: new Date().toISOString(),
  }));
}
