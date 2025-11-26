# Xcode Beginner Guide - Testing Readi iOS App

## Step 1: Open the Project

1. **Open Finder** (the blue and white face icon in your dock)
2. **Navigate to:** Desktop → Readi → apps → ios
3. **Double-click** `Readi.xcodeproj`
   - This will open Xcode (the blue icon with a hammer)

---

## Step 2: Wait for Xcode to Load

- Xcode will open and show your project
- You'll see a list of files on the left side
- This might take 30-60 seconds the first time

---

## Step 3: Select a Simulator (iPhone)

At the top of Xcode, you'll see a dropdown that probably says "iPhone 15 Pro" or similar.

1. **Click the dropdown** (next to the Play button)
2. **Select:** "iPhone 15 Pro" (or any iPhone simulator)
   - This is a fake iPhone that runs on your Mac
   - You don't need a real iPhone to test!

---

## Step 4: Build and Run the App

1. **Click the Play button** (▶️) at the top left of Xcode
   - OR press **Cmd + R** on your keyboard
2. **Wait for it to build** (30-60 seconds)
   - You'll see progress at the top
   - It might say "Building..." or show a progress bar
3. **The simulator will open automatically**
   - A window will pop up showing an iPhone screen
   - The Readi app will launch on it

---

## Step 5: Test the App

### What You Should See:

1. **Sign-In Screen**
   - Big "Readi" logo
   - "Sign in with Google" button

2. **Tap "Sign in with Google"**
   - A browser window will open
   - Sign in with your Google account
   - You'll be redirected back to the app

3. **Onboarding Screen**
   - Select "Job Seeker" or "Sales Professional"
   - Fill out the form
   - Tap "Get Started"

4. **Dashboard**
   - Should show "Upcoming Meetings"
   - Tap "Sync Calendar" button
   - Your meetings should appear!

---

## Common Issues & Fixes

### "Build Failed" Error
- **What it means:** Code has an error
- **What to do:** Tell me the error message and I'll fix it

### Simulator Won't Open
- **What to do:** 
  1. Go to Xcode menu → Window → Devices and Simulators
  2. Click "Simulators" tab
  3. Click "+" to add a simulator
  4. Select iPhone 15 Pro → Create

### App Crashes When Opening
- **What to do:** Check the bottom of Xcode for error messages
- Copy the error and tell me

### "Sign in with Google" Doesn't Work
- **What to check:** Make sure backend is running
- **How to check:** Open Terminal and run:
  ```bash
  curl http://localhost:4000/health
  ```
- Should return: `{"status":"ok",...}`

---

## Xcode Basics

### The Left Sidebar (File Navigator)
- Shows all your code files
- Click files to open them
- You don't need to edit anything right now

### The Center (Code Editor)
- Shows the code for the file you selected
- You can ignore this for now

### The Right Sidebar (Inspector)
- Usually hidden
- You can ignore this

### The Bottom (Console)
- Shows error messages
- If something breaks, check here

### Top Toolbar
- **Play button (▶️)**: Build and run
- **Stop button (⏹️)**: Stop the app
- **Device dropdown**: Select which iPhone to test on

---

## Quick Reference

**To run the app:**
- Click Play button (▶️) or press Cmd+R

**To stop the app:**
- Click Stop button (⏹️) or press Cmd+.

**To see errors:**
- Look at the bottom of Xcode window

**To close simulator:**
- Click the X on the simulator window

---

## What to Tell Me

If something doesn't work, tell me:
1. **What you were trying to do**
2. **What happened instead**
3. **Any error messages** (from bottom of Xcode)

I'll help you fix it!

