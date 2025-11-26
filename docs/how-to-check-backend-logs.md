# How to Check Backend Logs

## The Backend Terminal

The backend is running in a **background terminal**. Here's how to see the logs:

---

## Method 1: Find the Terminal Window

1. **Look for a Terminal window** on your Mac
2. It should be running `npm run dev:api`
3. You'll see logs scrolling there
4. **Look for error messages** when you try to sign in

---

## Method 2: Check Activity Monitor

1. Open **Activity Monitor** (search in Spotlight)
2. Look for processes named:
   - `node`
   - `tsx`
   - `npm`
3. These are the backend processes

---

## Method 3: Restart Backend in Foreground (EASIEST)

I can restart the backend so you can see the logs directly. The logs will show:
- ✅ When requests come in
- ❌ What errors occur
- 🔍 Detailed error messages

**Would you like me to restart it so you can see the logs?**

---

## What to Look For

When you try to sign in, the backend logs should show:

**If working:**
```
GET /api/v1/auth/google
GET /api/v1/auth/google/callback?code=...
User created/updated: ...
Redirecting to: readi://auth/callback?token=...
```

**If error:**
```
OAuth callback error: [specific error message]
Error: redirect_uri_mismatch
Error: invalid_grant
Error: Database connection failed
```

---

## Quick Fix: I'll Show You the Logs

I can check the backend logs for you right now. The error message will tell us exactly what's wrong!

