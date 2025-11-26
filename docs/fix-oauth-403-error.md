# Fix Google OAuth 403 Error: "org_internal"

## The Problem

**Error:** `Error 403: org_internal`
**Message:** "Readi is restricted to users within its organization"

This means your Google OAuth consent screen is either:
1. Set to "Internal" (Google Workspace only) instead of "External"
2. Your email isn't added as a test user

---

## Solution: Fix OAuth Consent Screen

### Step 1: Go to Google Cloud Console

1. Visit: https://console.cloud.google.com/
2. Select your **"Readi"** project
3. Go to **"APIs & Services"** → **"OAuth consent screen"**

### Step 2: Check User Type

**If it says "Internal":**
- This only works for Google Workspace accounts
- You need to change it to "External"

**If it says "External":**
- Good! But you need to add yourself as a test user

---

### Step 3A: Change to External (If Needed)

1. If it says **"Internal"**, click **"EDIT APP"**
2. At the top, you'll see **"User Type"**
3. Click **"External"** (unless you have a Google Workspace)
4. Click **"SAVE AND CONTINUE"**
5. Go through all the steps (you've done this before)
6. Make sure to click **"BACK TO DASHBOARD"** at the end

---

### Step 3B: Add Yourself as Test User (REQUIRED)

1. In **"OAuth consent screen"**, scroll down to **"Test users"** section
2. Click **"+ ADD USERS"**
3. **Add your email:** `ramifk88@gmail.com`
4. Click **"ADD"**
5. **IMPORTANT:** Make sure you see your email in the test users list

---

### Step 4: Verify Settings

Make sure you have:
- ✅ **User Type:** External
- ✅ **Test users:** Your email (`ramifk88@gmail.com`) is listed
- ✅ **Publishing status:** Testing (this is fine for now)

---

## Why This Happens

When OAuth consent screen is in "Testing" mode:
- Only test users can sign in
- If your email isn't in the test users list, you get the 403 error
- Once you publish the app (later), anyone can sign in

---

## After Fixing

1. **Wait 5-10 minutes** (Google needs time to update)
2. **Try signing in again** in the Readi app
3. You should now be able to sign in!

---

## Quick Checklist

- [ ] OAuth consent screen is set to "External"
- [ ] Your email (`ramifk88@gmail.com`) is in the test users list
- [ ] Waited 5-10 minutes after making changes
- [ ] Try signing in again

---

## Still Not Working?

If you still get the error after 10 minutes:
1. Double-check your email is spelled correctly in test users
2. Make sure you're using the same Google account
3. Try signing out and back in
4. Check if there are any other restrictions in Google Cloud Console

