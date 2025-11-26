# Complete Setup Guide for Readi

## ✅ What I Just Fixed (Apple Best Practices)

1. **OAuth Flow**: Updated to use `ASWebAuthenticationSession` (Apple's recommended way)
   - More secure than opening Safari directly
   - Better user experience
   - Follows Apple's Human Interface Guidelines

2. **Swift Best Practices Already in Code:**
   - ✅ `@MainActor` for UI updates
   - ✅ `@StateObject` / `@ObservedObject` for state management
   - ✅ `async/await` for networking
   - ✅ Keychain for secure token storage
   - ✅ MVVM architecture pattern

---

## Step-by-Step Setup (I'll Guide You Through Everything)

### Step 1: Install Homebrew (Package Manager)

Homebrew makes installing everything else easy.

**Copy and paste this in Terminal:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**After installation, add Homebrew to your PATH:**
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Verify it worked:**
```bash
brew --version
```

---

### Step 2: Install Node.js (Required for Backend)

```bash
brew install node@20
```

**Add to PATH:**
```bash
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

**Verify:**
```bash
node --version  # Should show v20.x
npm --version   # Should show 10.x
```

---

### Step 3: Install PostgreSQL (Database)

```bash
brew install postgresql@14
brew services start postgresql@14
```

**Create the database:**
```bash
createdb readi
```

**Verify it worked:**
```bash
psql -l | grep readi
```

---

### Step 4: Install Redis (Optional for Now)

```bash
brew install redis
brew services start redis
```

---

### Step 5: Get Google OAuth Credentials

1. **Go to:** https://console.cloud.google.com/
2. **Create a new project:**
   - Click "Select a project" → "New Project"
   - Name: "Readi"
   - Click "Create"

3. **Enable APIs:**
   - Go to "APIs & Services" → "Library"
   - Search and enable:
     - ✅ Google Calendar API
     - ✅ Gmail API

4. **Create OAuth Credentials:**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth 2.0 Client ID"
   - If prompted, configure OAuth consent screen first:
     - User Type: External
     - App name: Readi
     - Your email
     - Save and continue through all steps
   - Application type: **Web application**
   - Name: "Readi Web Client"
   - Authorized redirect URIs: `http://localhost:4000/api/v1/auth/google/callback`
   - Click "Create"
   - **Copy the Client ID and Client Secret**

5. **Update `.env` file:**
   ```bash
   # Open the .env file
   open -e /Users/ramikaawach/Desktop/Readi/.env
   ```
   
   Replace these lines:
   ```
   GOOGLE_CLIENT_ID=paste_your_client_id_here
   GOOGLE_CLIENT_SECRET=paste_your_client_secret_here
   ```

---

### Step 6: Install Project Dependencies

```bash
cd /Users/ramikaawach/Desktop/Readi
npm install
```

This will install all backend and web dependencies.

---

### Step 7: Setup Database

```bash
cd apps/backend
npm run db:generate  # Generate Prisma client
npm run db:push      # Create database tables
```

**If you get a database connection error:**
- Check your `.env` file has correct `DATABASE_URL`
- Default should be: `postgresql://postgres:password@localhost:5432/readi`
- If your PostgreSQL password is different, update it

---

### Step 8: Start the Backend

```bash
cd apps/backend
npm run dev
```

**You should see:**
```
Readi backend is listening { port: 4000, env: 'development' }
```

**Keep this terminal open!** The backend needs to keep running.

---

### Step 9: Open iOS App in Xcode

**In a NEW terminal window:**
```bash
open /Users/ramikaawach/Desktop/Readi/apps/ios/Readi.xcodeproj
```

**In Xcode:**
1. Select a simulator (iPhone 15 Pro recommended)
2. Press `Cmd + R` or click the Play button
3. App will build and launch

---

### Step 10: Test the App

1. **In the iOS app:**
   - Tap "Sign in with Google"
   - Complete Google sign-in
   - You should be redirected back to the app

2. **If sign-in works:**
   - You'll see the onboarding screen
   - Select your role (Job Seeker or Sales)
   - Fill out your profile

3. **After onboarding:**
   - Tap "Sync Calendar" to fetch your meetings
   - You should see your upcoming meetings!

---

## Troubleshooting

### "Command not found: npm"
- Node.js isn't installed or not in PATH
- Run: `brew install node@20` again
- Then: `source ~/.zprofile`

### "Database connection failed"
- Check PostgreSQL is running: `brew services list | grep postgresql`
- Verify database exists: `psql -l | grep readi`
- Check `.env` file has correct `DATABASE_URL`

### "Port 4000 already in use"
- Something else is using port 4000
- Change port in `.env`: `PORT=4001`
- Or kill the process: `lsof -ti:4000 | xargs kill`

### iOS app can't connect to backend
- Make sure backend is running (Step 8)
- Check `APIClient.swift` has `baseURL = "http://localhost:4000/api/v1"`
- For physical device: Use your Mac's IP address instead of localhost

### Google OAuth not working
- Verify redirect URI in Google Console matches exactly
- Check Client ID and Secret in `.env`
- Ensure Calendar and Gmail APIs are enabled

---

## Quick Reference Commands

```bash
# Start backend (always run this first)
cd /Users/ramikaawach/Desktop/Readi/apps/backend
npm run dev

# Open iOS project
open /Users/ramikaawach/Desktop/Readi/apps/ios/Readi.xcodeproj

# Database commands
cd apps/backend
npm run db:generate    # After schema changes
npm run db:push        # Push schema to database
npm run db:studio      # Open database GUI

# Check services
brew services list     # See what's running
```

---

## What's Next After Setup?

Once everything is running:
1. ✅ Test authentication
2. ✅ Sync calendar
3. ✅ View meetings
4. 🚧 **Build AI meeting prep** (the core feature!)

---

## Need Help?

If you get stuck at any step, just tell me:
- What command you ran
- What error message you saw
- I'll help you fix it!

