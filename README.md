# Readi

Readi is an AI meeting-prep assistant focused on account executives and job seekers. It aggregates calendar events, emails, Slack history, user-provided context, and trusted public research to deliver actionable briefs before every meeting.

## Project Structure

```
apps/
  backend/        # Fastify API, integrations, and orchestration services
  ios/            # Native iOS app (SwiftUI)
  web/            # Next.js responsive web app
packages/
  design-tokens/  # Shared design system for mobile and web
docs/            # Documentation and roadmap
```

## Getting Started

### Prerequisites

- Node.js 20+
- npm 10+
- PostgreSQL 14+
- Redis 7+
- Xcode 15+ (for iOS development)

### Environment Setup

1. Copy `.env.example` to `.env` in the root and configure:
   ```bash
   cp .env.example .env
   ```

2. Required environment variables:
   - `DATABASE_URL`: PostgreSQL connection string
   - `JWT_SECRET`: Secret for JWT tokens (min 32 characters)
   - `GOOGLE_CLIENT_ID` & `GOOGLE_CLIENT_SECRET`: Google OAuth credentials
   - `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`: AI provider API key
   - `REDIS_URL`: Redis connection string

### Installation

```bash
# Install all dependencies
npm install

# Generate design tokens
npm run build:tokens

# Generate Prisma client
cd apps/backend && npm run db:generate

# Push database schema
npm run db:push
```

### Development

```bash
# Start backend API
npm run dev:api

# Start web app
npm run dev:web

# Open iOS project in Xcode
open apps/ios/Readi.xcodeproj
```

### Database

```bash
# Generate Prisma client
npm run db:generate --workspace apps/backend

# Push schema to database
npm run db:push --workspace apps/backend

# Create migration
npm run db:migrate --workspace apps/backend

# Open Prisma Studio
npm run db:studio --workspace apps/backend
```

## Scripts

- `npm run dev:api` – Start backend server
- `npm run dev:web` – Start web development server
- `npm run build:tokens` – Generate design tokens for iOS and web
- `npm run lint` – Run linters across all workspaces
- `npm run format` – Format code with Prettier

## Documentation

- [Roadmap](/docs/roadmap.md) – Development milestones
- [Design Tokens](/packages/design-tokens/) – Shared design system

## Tech Stack

**Backend:**
- Fastify (API framework)
- Prisma (ORM)
- PostgreSQL (database)
- BullMQ + Redis (job queue)
- Google APIs (Calendar, Gmail)
- OpenAI/Anthropic (AI)

**iOS:**
- SwiftUI
- Combine
- GoogleSignIn SDK

**Web:**
- Next.js 14
- React 18
- TypeScript

## License

MIT
