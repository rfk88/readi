# Database & Backend Status

## ✅ Database Status

**Location:** Supabase-managed PostgreSQL (db.fbkdhjcfkxvnjgdksmre.supabase.co:5432)  
**Database Name:** `postgres` (Supabase default)  
**Status:** ✅ **ACTIVE & CONFIGURED**

### What's in the Database:
- ✅ User accounts (created when users sign in with Google)
- ✅ User profiles (role, job details, company info)
- ✅ Google OAuth tokens (for accessing Calendar/Gmail)
- ✅ Calendar events (synced from Google Calendar)
- ✅ Email threads (synced from Gmail)
- ✅ Meeting participants
- ✅ Talking points (AI-generated)
- ✅ Company research data

### Database Connection:
- Connection string stored in `.env` via `DATABASE_URL` (Supabase Postgres).  
- Supabase handles credentials; Prisma connects using that URL.

**This is a REAL database** - not a test database. All data persists and is stored permanently.

---

## ✅ Backend Status

**Location:** Node.js server running on your Mac  
**Port:** 4000  
**URL:** `http://localhost:4000`  
**Status:** ✅ **RUNNING**

### What the Backend Does:
1. **Authentication** - Handles Google OAuth sign-in
2. **User Management** - Creates/updates user accounts
3. **Profile Management** - Stores user profiles (job seeker or sales)
4. **Calendar Sync** - Fetches events from Google Calendar
5. **Email Sync** - Fetches emails from Gmail
6. **AI Integration** - Generates talking points (mock by default; real once OpenAI key added)

### API Endpoints:
- `GET /api/v1/health` - Health check
- `GET /api/v1/auth/google` - Start Google OAuth
- `GET /api/v1/auth/google/callback` - OAuth callback
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/profiles` - Create/update profile
- `GET /api/v1/profiles/me` - Get user profile
- `GET /api/v1/meetings/upcoming` - Get upcoming meetings
- `POST /api/v1/meetings/sync` - Sync calendar
- `POST /api/v1/meetings/:id/generate-prep` - Create talking points
- `GET /api/v1/meetings/:id/talking-points` - Fetch saved prep
- `POST /api/v1/meetings/:id/feedback` - Store prep feedback

---

## 🔄 New User Flow (Implemented)

### Step 0: Welcome Screen
- Shows app features
- "Get Started" button

### Step 1: Onboarding - Name + Role
- User enters their name
- User selects role: "Job Seeker" or "Sales Professional"
- "Continue" button

### Step 2: Google Sign-In
- User connects Google account
- Backend creates user account
- Stores Google OAuth tokens

### Step 3: Profile Details
- **Job Seeker:** Job role, target company, resume URL
- **Sales:** Company name, product description
- "Get Started" button saves profile

### Step 4: Dashboard
- Shows upcoming meetings
- User can open a meeting and tap “View/Generate Talking Points”

---

## 🔐 Data Persistence

**Users don't need to onboard again!**

- ✅ User account persists in database
- ✅ Profile persists in database
- ✅ Auth token stored in iOS Keychain
- ✅ On next app launch: User goes straight to Dashboard

---

## 🧪 Testing the Flow

1. **Open iOS app in Xcode:**
   ```bash
   open apps/ios/Readi.xcodeproj
   ```

2. **Build and run** (Cmd+R)

3. **Test the flow:**
   - See Welcome screen
   - Enter name + select role
   - Sign in with Google
   - Fill profile details
   - See Dashboard

4. **Talking points:**
   - Tap “Sync Calendar”
   - Open a meeting → tap “View/Generate Talking Points”
   - Should see placeholder tips (real AI when key is present)

---

## 🔧 Troubleshooting

### "Connection Refused" Error
- **Cause:** Backend not running
- **Fix:** Start backend:
  ```bash
  cd /Users/ramikaawach/Desktop/Readi
  npm run dev:api
  ```

### Database Connection Error
- **Cause:** Supabase credentials missing or Prisma not pointed at `DATABASE_URL`
- **Fix:** Check `.env` for the Supabase connection string and rerun `npx prisma db push`

### Check Backend Status
```bash
curl http://localhost:4000/api/v1/health
# Should return: {"status":"ok","service":"readi-backend",...}
```

### View Database Data
```bash
cd apps/backend
npm run db:studio
# Opens Prisma Studio in browser - view all your data!
```

---

## 📊 Database Schema

The database has these main tables:
- `users` - User accounts
- `user_tokens` - Google OAuth tokens
- `profiles` - User profiles (role, job details, etc.)
- `calendar_events` - Synced calendar events
- `meeting_participants` - People in meetings
- `email_threads` - Email conversations
- `email_messages` - Individual emails
- `meeting_email_links` - Links between meetings and emails
- `talking_points` - AI-generated talking points
- `company_research` - Company information
- `contacts` - Contact information

---

## ✅ Summary

- **Database:** ✅ Real PostgreSQL database, fully configured, storing real data
- **Backend:** ✅ Running on port 4000, handling all API requests
- **User Flow:** ✅ Welcome → Onboarding → Google Sign-in → Profile → Dashboard
- **Data Persistence:** ✅ Users don't need to onboard again

**Everything is ready for building and testing with real data!**

