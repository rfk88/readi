# Fix Info.plist Build Error - Manual Steps

## The Problem
Xcode is trying to both auto-generate Info.plist AND use our manual one, causing a conflict.

## Quick Fix (2 minutes)

### Step 1: In Xcode, Remove Info.plist from Copy Bundle Resources

1. **In the left sidebar**, click on **"Readi"** (the blue project icon at the very top)
2. **Click on the "Readi" target** (under TARGETS, not PROJECTS)
3. **Click "Build Phases" tab** (at the top)
4. **Expand "Copy Bundle Resources"** (click the arrow)
5. **Find "Info.plist"** in the list
6. **Select it** and press **Delete** (or click the minus button)
7. **Click "Remove"** when prompted

### Step 2: Clean Build Folder

1. In Xcode menu: **Product** → **Clean Build Folder** (or press **Shift + Cmd + K**)
2. Wait for it to finish

### Step 3: Try Building Again

1. Click **Play button** (▶️) or press **Cmd + R**
2. Should build successfully now!

---

## Alternative: Let Me Fix It Programmatically

If the above doesn't work, I can try a different approach. Just let me know!

