# Google API Setup Guide

## Required APIs & Scopes

Readi needs access to:
1. **Google Calendar API** - To read your meetings
2. **Gmail API** - To read emails related to meetings
3. **OAuth 2.0** - To authenticate users

## Step-by-Step Setup

### Step 1: Go to Google Cloud Console

1. Visit: https://console.cloud.google.com/
2. Sign in with your Google account

### Step 2: Create a New Project

1. Click the project dropdown at the top
2. Click "New Project"
3. Project name: **Readi**
4. Click "Create"
5. Wait for project to be created (30 seconds)

### Step 3: Enable Required APIs

1. In the left sidebar, go to **"APIs & Services"** → **"Library"**
2. Search for and enable these APIs (one at a time):
   - ✅ **Google Calendar API** - Click "Enable"
   - ✅ **Gmail API** - Click "Enable"

### Step 4: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** → **"OAuth consent screen"**
2. Select **"External"** (unless you have a Google Workspace)
3. Click "Create"
4. Fill out the form:
   - **App name**: Readi
   - **User support email**: Your email
   - **Developer contact email**: Your email
5. Click "Save and Continue"
6. **Scopes** (Step 2):
   - Click "Add or Remove Scopes"
   - Add these scopes:
     - `.../auth/userinfo.email`
     - `.../auth/userinfo.profile`
     - `.../auth/calendar.readonly`
     - `.../auth/gmail.readonly`
   - Click "Update" then "Save and Continue"
7. **Test users** (Step 3):
   - Add your email as a test user
   - Click "Save and Continue"
8. **Summary** (Step 4):
   - Review and click "Back to Dashboard"

### Step 5: Create OAuth 2.0 Credentials

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** → **"OAuth 2.0 Client ID"**
3. If prompted, select **"Web application"**
4. Fill out:
   - **Name**: Readi Web Client
   - **Authorized redirect URIs**: 
     - `http://localhost:4000/api/v1/auth/google/callback`
   - Click "Create"
5. **IMPORTANT**: Copy these values immediately (you won't see the secret again):
   - **Client ID** (looks like: `123456789-abc.apps.googleusercontent.com`)
   - **Client secret** (looks like: `GOCSPX-abc123xyz`)

### Step 6: Update Your .env File

1. Open your `.env` file:
   ```bash
   open -e /Users/ramikaawach/Desktop/Readi/.env
   ```

2. Replace these lines with your actual credentials:
   ```
   GOOGLE_CLIENT_ID=paste_your_client_id_here
   GOOGLE_CLIENT_SECRET=paste_your_client_secret_here
   ```

3. Save the file

### Step 7: Restart Backend

After updating `.env`, restart the backend:
```bash
# Stop the current backend (Ctrl+C if running)
# Then restart:
cd /Users/ramikaawach/Desktop/Readi
npm run dev:api
```

## Verification

Once set up, you can test:
1. Open iOS app in Xcode
2. Tap "Sign in with Google"
3. You should see Google's sign-in page
4. After signing in, you'll be redirected back to the app

## Troubleshooting

### "Redirect URI mismatch"
- Make sure the redirect URI in Google Console is EXACTLY:
  `http://localhost:4000/api/v1/auth/google/callback`
- No trailing slash, exact match

### "Access blocked: This app's request is invalid"
- Make sure you added yourself as a test user in OAuth consent screen
- The app is in "Testing" mode, so only test users can sign in

### "API not enabled"
- Go back to APIs & Services → Library
- Make sure both Calendar API and Gmail API show "Enabled"

### Can't find Client Secret
- If you lost it, go to Credentials → Your OAuth client → Edit
- You can reset the secret there

## Production Setup (Later)

When ready for production:
1. Submit OAuth consent screen for verification
2. Add production redirect URIs:
   - `https://yourdomain.com/api/v1/auth/google/callback`
   - `readi://auth/callback` (for iOS deep link)
3. Update `.env` with production URLs

