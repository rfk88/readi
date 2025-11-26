# Fix OAuth Callback Error

## The Problem

After approving Google permissions, you get:
```json
{
  "error": {
    "code": "OAUTH_ERROR",
    "message": "Failed to complete authentication"
  }
}
```

---

## Common Causes

### 1. Redirect URI Mismatch (MOST COMMON)

**The redirect URI in Google Cloud Console must EXACTLY match what the backend expects.**

**Check in Google Cloud Console:**
1. Go to **APIs & Services** → **Credentials**
2. Click your OAuth 2.0 Client ID
3. Check **Authorized redirect URIs**
4. Must have: `http://localhost:4000/api/v1/auth/google/callback`
5. **EXACT match** - no trailing slash, exact case

**Check in .env:**
```bash
GOOGLE_REDIRECT_URI=http://localhost:4000/api/v1/auth/google/callback
```

**They must match exactly!**

---

### 2. Missing Environment Variables

**Check if these are set:**
- `GOOGLE_CLIENT_ID` - Your client ID
- `GOOGLE_CLIENT_SECRET` - Your client secret
- `GOOGLE_REDIRECT_URI` - Must match Google Console
- `DATABASE_URL` - Database connection
- `JWT_SECRET` - JWT signing secret

---

### 3. Database Connection Issue

**If database isn't accessible:**
- Check PostgreSQL is running
- Check `DATABASE_URL` is correct
- Try: `cd apps/backend && npm run db:push`

---

### 4. Google API Not Enabled

**Make sure these are enabled:**
- Google Calendar API
- Gmail API
- OAuth 2.0

---

## How to Debug

### Step 1: Check Backend Logs

The backend should log the actual error. Look for:
- Error messages in terminal where backend is running
- Should show what specifically failed

### Step 2: Verify Redirect URI

**In Google Cloud Console:**
- Credentials → Your OAuth Client
- Authorized redirect URIs must include:
  ```
  http://localhost:4000/api/v1/auth/google/callback
  ```

**In .env file:**
```bash
GOOGLE_REDIRECT_URI=http://localhost:4000/api/v1/auth/google/callback
```

### Step 3: Test Direct Callback

Try visiting this URL directly (replace CODE with actual code):
```
http://localhost:4000/api/v1/auth/google/callback?code=CODE
```

---

## Quick Fix Checklist

- [ ] Redirect URI in Google Console matches `.env` exactly
- [ ] All environment variables are set
- [ ] Database is running and accessible
- [ ] Google APIs are enabled
- [ ] Backend is running and accessible
- [ ] Check backend logs for specific error

---

## Most Likely Fix

**90% of the time it's a redirect URI mismatch.**

1. Go to Google Cloud Console
2. Credentials → Your OAuth Client
3. Make sure redirect URI is: `http://localhost:4000/api/v1/auth/google/callback`
4. Save
5. Wait 5 minutes
6. Try again

---

## After Fixing

1. **Restart backend** (if you changed .env)
2. **Wait 5-10 minutes** (Google needs time to update)
3. **Try signing in again**

The error message should now include more details about what failed.

