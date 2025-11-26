# Readi Setup Guide

## Step 1: Install Prerequisites

### Install Node.js (Required for Backend)

**Option A: Using Homebrew (Recommended)**
```bash
brew install node@20
```

**Option B: Download from nodejs.org**
- Visit: https://nodejs.org/
- Download LTS version (20.x or higher)
- Install the .pkg file

**Verify Installation:**
```bash
node --version  # Should show v20.x or higher
npm --version   # Should show 10.x or higher
```

### Install PostgreSQL (Required for Database)

**Using Homebrew:**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Create Database:**
```bash
createdb readi
```

### Install Redis (Optional - for job queue later)

```bash
brew install redis
brew services start redis
```

---

## Step 2: Configure Environment

The `.env` file has been created with a secure JWT secret. You need to:

1. **Get Google OAuth Credentials:**
   - Go to https://console.cloud.google.com/
   - Create a new project (or select existing)
   - Enable "Google Calendar API" and "Gmail API"
   - Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
   - Application type: "Web application"
   - Authorized redirect URIs: `http://localhost:4000/api/v1/auth/google/callback`
   - Copy the Client ID and Client Secret

2. **Update `.env` file:**
   ```bash
   # Edit the .env file and replace:
   GOOGLE_CLIENT_ID=your_actual_client_id_here
   GOOGLE_CLIENT_SECRET=your_actual_client_secret_here
   
   # Update database URL if different:
   DATABASE_URL=postgresql://postgres:your_password@localhost:5432/readi
   ```

---

## Step 3: Install Dependencies & Setup Database

```bash
# Navigate to project
cd /Users/ramikaawach/Desktop/Readi

# Install all dependencies
npm install

# Generate Prisma client
cd apps/backend
npm run db:generate

# Push database schema (creates tables)
npm run db:push
```

---

## Step 4: Start the Backend

```bash
# From apps/backend directory
npm run dev
```

The backend will start at: **http://localhost:4000**

You should see:
```
Readi backend is listening { port: 4000, env: 'development' }
```

---

## Step 5: Run iOS App

1. **Open Xcode:**
   ```bash
   open apps/ios/Readi.xcodeproj
   ```

2. **Select a Simulator:**
   - iPhone 15 Pro (recommended)
   - Or any iOS 16+ device

3. **Build & Run:**
   - Press `Cmd + R` or click the Play button
   - The app will launch in the simulator

4. **Test Auth Flow:**
   - Tap "Sign in with Google"
   - Complete Google sign-in
   - App should receive token and show dashboard

---

## Troubleshooting

### Backend won't start
- Check `.env` file exists and has valid values
- Ensure PostgreSQL is running: `brew services list | grep postgresql`
- Check database exists: `psql -l | grep readi`

### Database connection error
- Verify DATABASE_URL in `.env` matches your PostgreSQL setup
- Try: `psql -U postgres -d readi` to test connection

### iOS app can't connect to backend
- Ensure backend is running on port 4000
- Check `APIClient.swift` has correct baseURL
- For simulator, `localhost` should work
- For physical device, use your Mac's IP address

### Google OAuth not working
- Verify redirect URI matches exactly in Google Console
- Check Client ID and Secret in `.env`
- Ensure Calendar and Gmail APIs are enabled

---

## Next Steps After Setup

Once everything is running:
1. ✅ Test authentication flow
2. ✅ Sync calendar (tap "Sync Calendar" in app)
3. ✅ View upcoming meetings
4. 🚧 Build AI meeting prep feature (next priority)

---

## Quick Commands Reference

```bash
# Start backend
cd apps/backend && npm run dev

# Start web app (when ready)
cd apps/web && npm run dev

# Database commands
cd apps/backend
npm run db:generate    # Generate Prisma client
npm run db:push        # Push schema to database
npm run db:studio      # Open Prisma Studio (database GUI)
npm run db:migrate     # Create migration

# View logs
# Backend logs appear in terminal where you ran `npm run dev`
```

