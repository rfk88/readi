# OAuth Error Debugging Guide

## Current Issue

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

## What I Just Fixed

1. **Better error detection** - Backend now detects simulator/device better
2. **Error details in response** - You'll now see the actual error message
3. **Error handling in iOS** - App can now show the specific error

---

## How to See the Actual Error

### Option 1: Check Xcode Console (EASIEST)

1. **In Xcode**, look at the **bottom panel** (Console)
2. When you try to sign in, you'll see error messages there
3. The error will show what specifically failed

### Option 2: Check Backend Terminal

The backend is running in a background terminal. The error logs are there, but they're hard to see.

**I've improved the error logging** - the backend will now:
- Log detailed errors to console
- Show error details in the response
- Help identify the exact problem

---

## Common OAuth Errors

### 1. "redirect_uri_mismatch"
**Fix:** Redirect URI in Google Console must exactly match `.env`

### 2. "invalid_grant" 
**Fix:** Authorization code expired or already used (try again)

### 3. "Database connection failed"
**Fix:** PostgreSQL not running or DATABASE_URL wrong

### 4. "No access token received"
**Fix:** Google didn't return token (check scopes, consent screen)

---

## Next Steps

1. **Try signing in again** in the simulator
2. **Check Xcode console** (bottom panel) for the error message
3. **Tell me the exact error** you see
4. I'll fix it!

The error message will now be much more specific and helpful.

---

## What to Look For

In Xcode console, you should see something like:
- `Error: redirect_uri_mismatch`
- `Error: Database connection failed`
- `Error: No access token received`

This will tell us exactly what's wrong!

