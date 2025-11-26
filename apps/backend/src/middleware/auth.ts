import type { FastifyRequest, FastifyReply } from 'fastify';
import { env } from '../config/env.js';

export interface AuthenticatedRequest extends FastifyRequest {
  user: {
    userId: string;
    email: string;
  };
}

export async function authenticate(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    await request.jwtVerify();
    
    const payload = request.user as { userId: string; email: string };
    
    if (!payload.userId || !payload.email) {
      return reply.code(401).send({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Invalid token payload',
        },
      });
    }
    
    (request as AuthenticatedRequest).user = payload;
  } catch (error) {
    return reply.code(401).send({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Invalid or expired token',
      },
    });
  }
}

