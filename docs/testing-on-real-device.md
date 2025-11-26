# Testing on Real iPhone/iPad

## The Problem

When testing on a **real device** (not simulator):
- `localhost` refers to the **device itself**, not your Mac
- The backend runs on your **Mac**, not the device
- You need to use your **Mac's IP address** instead

---

## Solution: Use Mac's IP Address

### Your Mac's IP: `192.168.70.198`

The app is now configured to:
- Use `localhost:4000` in **simulator** (works automatically)
- Use `192.168.70.198:4000` on **real device** (your Mac's IP)

---

## Requirements

### 1. Mac and iPhone on Same Network

Both devices must be on the **same Wi-Fi network**:
- ✅ Mac connected to Wi-Fi
- ✅ iPhone connected to **same Wi-Fi**
- ❌ Can't use different networks

### 2. Backend Must Be Running

Make sure the backend is running on your Mac:
```bash
cd /Users/ramikaawach/Desktop/Readi
npm run dev:api
```

### 3. Firewall Settings

Your Mac's firewall might block connections. If it doesn't work:

1. **System Settings** → **Network** → **Firewall**
2. Make sure firewall allows incoming connections
3. Or temporarily disable firewall for testing

---

## Testing Steps

### Step 1: Start Backend

```bash
cd /Users/ramikaawach/Desktop/Readi
npm run dev:api
```

You should see: `Server listening on http://0.0.0.0:4000`

### Step 2: Connect iPhone

1. Connect iPhone to Mac via USB
2. Trust the computer (if prompted)

### Step 3: Build on Device

1. In Xcode, select your **iPhone** (not simulator)
2. Click Play button (▶️)
3. App installs on your device

### Step 4: Test Sign-In

1. Open the Readi app on your iPhone
2. Tap "Sign in with Google"
3. Should now connect to your Mac's backend!

---

## If It Still Doesn't Work

### Check Backend is Accessible

On your iPhone's Safari, try visiting:
```
http://192.168.70.198:4000/health
```

If this works, the backend is accessible. If not:
- Check Mac and iPhone are on same Wi-Fi
- Check Mac's firewall settings
- Try restarting the backend

### Update IP Address

If your Mac's IP changes (it can change when you reconnect to Wi-Fi):

1. **Find new IP:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. **Update in code:**
   - `apps/ios/Readi/Services/APIClient.swift`
   - `apps/ios/Readi/Services/AuthService.swift`
   - Replace `192.168.70.198` with your new IP

---

## Production Note

In production, you'll use a real domain like:
- `https://api.readi.app/api/v1`

This local IP setup is only for development/testing.

