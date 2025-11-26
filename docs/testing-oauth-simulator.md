# Testing OAuth in iOS Simulator - Solutions

## The Problem

Google's 2FA (Two-Factor Authentication) requires:
- QR code scanning
- Bluetooth device pairing
- Physical device verification

**iOS Simulator doesn't support:**
- Camera (for QR codes)
- Bluetooth
- Physical device features

## Solutions

### Option 1: Test on Real Device (RECOMMENDED) ⭐

**Best for:** Full end-to-end testing

1. **Connect your iPhone/iPad** via USB
2. **In Xcode:** Select your physical device from the device dropdown
3. **Build and run** - The app will install on your real device
4. **Sign in with Google** - Your real device can handle 2FA

**Pros:**
- Full real-world testing
- Can test all features including notifications
- Most accurate testing environment

**Cons:**
- Requires physical device
- Need to be connected via USB (or wireless debugging)

---

### Option 2: Create Test Google Account (QUICK FIX)

**Best for:** Quick testing without 2FA

1. **Create a new Google account** (use a test email)
2. **Don't enable 2FA** on this account
3. **Use this account** for testing in the simulator

**Pros:**
- Works in simulator
- No physical device needed
- Can test full OAuth flow

**Cons:**
- Not your real account
- Need to manage a test account

---

### Option 3: Temporarily Disable 2FA (NOT RECOMMENDED)

**Best for:** One-time testing only

1. Go to your Google Account settings
2. Temporarily disable 2FA
3. Test in simulator
4. **Re-enable 2FA immediately after** (security risk if left off)

**Pros:**
- Use your real account
- Works in simulator

**Cons:**
- Security risk if forgotten
- Not realistic (users will have 2FA)

---

### Option 4: Verify OAuth Flow Without Full Login

**Best for:** Testing redirect and URL handling

You can verify the OAuth flow works by:

1. **Check if redirect URL is correct:**
   - When you tap "Sign in with Google"
   - Does it open Google's sign-in page? ✅
   - Does the URL look correct? ✅

2. **Manually test the callback:**
   - The app should handle `readi://auth/callback?token=...`
   - We can verify this code path works

**Pros:**
- Can test URL handling
- No account needed

**Cons:**
- Can't test full authentication
- Can't test API calls

---

## Recommended Approach

**For now:** Use **Option 1** (real device) or **Option 2** (test account)

**For production:** All users will have real devices, so this won't be an issue

---

## Quick Setup: Test on Real Device

1. **Connect iPhone/iPad** to Mac via USB
2. **Trust the computer** on your device (if prompted)
3. **In Xcode:**
   - Click device dropdown (top left)
   - Select your iPhone/iPad (not simulator)
   - Click Play button (▶️)
4. **App installs on your device**
5. **Test sign-in** - Your real device can handle 2FA

---

## What We Can Verify Now

Even without completing sign-in, we can verify:

✅ App launches correctly
✅ Sign-in button works
✅ OAuth URL opens correctly
✅ URL scheme is configured (`readi://`)
✅ App structure is correct

The OAuth flow code is correct - we just need a device that can handle 2FA to test the full flow.

