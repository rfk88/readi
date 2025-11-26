# Troubleshooting: iPhone Can't Connect to Backend

## The Problem

iPhone shows "Safari can't connect to the server" when trying to sign in.

---

## Quick Checks

### 1. Same Wi-Fi Network? ✅

**Both devices must be on the same Wi-Fi:**
- Mac connected to Wi-Fi
- iPhone connected to **same Wi-Fi network**
- ❌ Can't be on different networks

**How to check:**
- Mac: System Settings → Wi-Fi → see network name
- iPhone: Settings → Wi-Fi → see network name
- **They must match!**

---

### 2. Mac Firewall Blocking? 🔥

**Mac's firewall might be blocking connections:**

1. **System Settings** → **Network** → **Firewall**
2. Check if firewall is ON
3. If ON, you have two options:

**Option A: Allow incoming connections**
- Click "Options" or "Firewall Options"
- Make sure "Block all incoming connections" is OFF
- Or add an exception for Node.js

**Option B: Temporarily disable (for testing)**
- Turn firewall OFF temporarily
- Test if it works
- Turn it back ON after testing

---

### 3. IP Address Changed? 📍

**Your Mac's IP might have changed** when you reconnected to Wi-Fi.

**Check current IP:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**If IP changed:**
- Update `apps/ios/Readi/Services/APIClient.swift`
- Update `apps/ios/Readi/Services/AuthService.swift`
- Replace `192.168.70.198` with your new IP

---

### 4. Test Backend Accessibility

**On your iPhone's Safari, try visiting:**
```
http://192.168.70.198:4000/health
```

**If this works:**
- ✅ Backend is accessible
- ✅ Network is fine
- Issue might be with OAuth redirect URL

**If this doesn't work:**
- ❌ Backend not accessible
- Check firewall
- Check same Wi-Fi network
- Check IP address

---

## Step-by-Step Fix

### Step 1: Verify Same Network
- Mac and iPhone on same Wi-Fi? ✅

### Step 2: Check Firewall
- Mac firewall allowing connections? ✅

### Step 3: Test Direct Access
- Can iPhone Safari reach `http://192.168.70.198:4000/health`? ✅

### Step 4: Update IP if Changed
- Check Mac's current IP
- Update in iOS code if different

### Step 5: Rebuild App
- Clean build in Xcode
- Rebuild and try again

---

## Alternative: Use Simulator for Now

If real device testing is too complicated:
- ✅ Simulator works perfectly
- ✅ Can test full OAuth flow (with test account)
- ✅ No network/firewall issues
- ✅ Faster iteration

You can test on real device later when everything else is working.

---

## Most Common Issue

**90% of the time it's:**
- Mac and iPhone on **different Wi-Fi networks**
- Or Mac's **firewall blocking** connections

Check these first!

