import { env } from './config/env.js';
import { createServer } from './server.js';

async function bootstrap() {
  const app = createServer();

  try {
    await app.listen({ port: env.PORT, host: '0.0.0.0' });
    app.log.info(
      { port: env.PORT, env: env.NODE_ENV },
      'Readi backend is listening'
    );
  } catch (error) {
    app.log.error(error, 'Failed to start backend');
    process.exit(1);
  }
}

bootstrap();
