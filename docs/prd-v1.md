# Readi V1 PRD

## 1. Product Overview
- **Purpose:** Readi prepares job seekers and sales professionals for meetings by summarizing the meeting context, related emails, and public research into actionable tips delivered 15–30 minutes before the meeting.
- **Platforms:** Native iOS (iPhone/iPad + Mac Catalyst). Backend: Fastify/Prisma with Supabase Postgres. AI: OpenAI (initial model GPT-4o mini or similar).
- **Integrations (V1 scope):** Google Calendar + Gmail (OAuth flow already implemented). Slack/Microsoft Teams deferred.

## 2. Target Users & Use Cases
1. **Job Seekers**
   - Goal: prep for interviews by referencing target company info, interviewer history, and relevant emails.
   - Key data: resume link, target role, target company, “why me” notes.
2. **Sales Professionals**
   - Goal: prep for live deals by recalling customer pain points, email threads, and differentiators.
   - Key data: company name, product description, ICP/pain, deal stage (optional note).

## 3. MVP Feature Set
1. **Onboarding Flow**
   - Welcome screen explaining value.
   - Step 1: capture name + role (job seeker or sales).
   - Step 2: connect Google (ASWebAuthenticationSession).
   - Step 3: role-specific profile fields (see Section 4).
   - Persist onboarding state so returning users land on dashboard.
2. **Google Sync**
   - `POST /meetings/sync` hits Google Calendar + Gmail.
   - Store events, attendees, linked email threads.
3. **AI Meeting Prep**
   - `/meetings/:id/generate-prep` aggregates:
     - User profile (name, role, resume/company context).
     - Meeting info (attendees, description, start time).
     - Recent emails referencing participants.
   - Calls OpenAI with tailored prompt (job seeker vs sales).
   - Persists talking points + metadata.
4. **Dashboard + Prep View**
   - Dashboard shows upcoming meetings with “Prep ready / generate” status.
   - Tapping a meeting opens `TalkingPointsView` with AI output, email snippets, and quick actions.

## 4. Data Model Requirements (V1)
### User (existing)
| Field | Type | Notes |
| --- | --- | --- |
| id | string | Prisma `cuid()` |
| email | string | Google account |
| name | string | Captured during onboarding |

### Profile (expand)
| Field | Type | Applies to | Required? |
| --- | --- | --- | --- |
| role | enum (`job_seeker` / `sales`) | both | ✅ |
| displayName | string | both | optional |
| timeZone | string | both | ✅ |
| reminderMinutes | int (`15`,`30`,`60`) | both | default `30` |
| preferredMeetingTypes | string[] | both | optional |
| notificationPreference | enum (`push`, `email`, `both`) | both | default `push` |
| notes | text | both | optional |
| resumeUrl | string | job seeker | optional |
| jobRole | string | job seeker | ✅ |
| targetCompanies | string[] | job seeker | ✅ (≥1) |
| companyName | string | sales | ✅ |
| productDescription | text | sales | ✅ |
| salesPainPoints | text | sales | optional |
| salesTargets | text | sales | optional |

### Meeting / Talking Points (existing schema ok for now)
- Ensure `meeting` references `userId`, stores attendees, start time.
- Add `talkingPoints` model storing `meetingId`, `content`, `createdAt`, `sourceEmails`.

## 5. User Flows
1. **First Run**
   1. WelcomeView → “Get Started”.
   2. SignInView → Google OAuth (ASWebAuthenticationSession).
   3. RoleSelectionStep → choose Job Seeker or Sales.
   4. ProfileSetupView → role-specific fields (shared + preferences).
   5. Auto-sync calendar → Dashboard (empty state explains “Sync meetings”).
2. **Generate Prep**
   1. User taps “Sync calendar” → backend fetches events/emails.
   2. Dashboard shows meeting cards. User taps a meeting → `MeetingDetailView`.
   3. If no talking points: button “Generate Prep” calls `/meetings/:id/generate-prep`.
   4. Once done: `TalkingPointsView` lists bullet points, highlights key emails, allows “Mark helpful” feedback.

## 6. Success Metrics
- 100% of new users can finish onboarding + connect Google without errors.
- At least 1 meeting shows up with generated talking points after sync.
- App relaunch takes user straight to dashboard (no repeated onboarding).
- AI generation latency < 8 seconds for first draft (stretch).

## 7. Out of Scope for V1
- Slack/Microsoft Teams integrations.
- Automated scheduled prep (BullMQ/APNs).
- Web/PWA or Android builds.
- Multi-user org features or collaboration.

## 8. Dependencies / Open Questions
- Confirm OpenAI API key and model tier for production testing.
- Decide whether resume uploads happen now or remain URL-only.
- Logging/monitoring plan for Supabase + backend (Sentry?).

