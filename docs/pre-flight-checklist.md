# Pre-Flight Checklist - Before Testing Readi

## ✅ Infrastructure Setup (DONE)

- [x] Homebrew installed
- [x] Node.js 20 installed
- [x] PostgreSQL installed and running
- [x] Redis installed and running
- [x] Database created (`readi`)
- [x] Database schema pushed
- [x] Dependencies installed
- [x] Backend server running

## ⚠️ Required Configuration (DO THIS NOW)

### Google OAuth Setup

- [ ] **Google Cloud Project created**
  - Go to: https://console.cloud.google.com/
  - Create project named "Readi"

- [ ] **APIs Enabled**
  - [ ] Google Calendar API enabled
  - [ ] Gmail API enabled

- [ ] **OAuth Consent Screen configured**
  - [ ] App name: Readi
  - [ ] Scopes added:
    - userinfo.email
    - userinfo.profile
    - calendar.readonly
    - gmail.readonly
  - [ ] Your email added as test user

- [ ] **OAuth 2.0 Credentials created**
  - [ ] Client ID copied
  - [ ] Client Secret copied
  - [ ] Redirect URI set: `http://localhost:4000/api/v1/auth/google/callback`

- [ ] **.env file updated**
  - [ ] `GOOGLE_CLIENT_ID` = your actual client ID
  - [ ] `GOOGLE_CLIENT_SECRET` = your actual client secret
  - [ ] Backend restarted after updating

### AI Provider Setup (For Next Phase)

- [ ] **OpenAI API Key** (or Anthropic)
  - Get from: https://platform.openai.com/api-keys
  - Add to `.env`: `OPENAI_API_KEY=sk-...`

## 🧪 Testing Checklist

Once Google OAuth is set up:

- [ ] Backend health check works: `curl http://localhost:4000/health`
- [ ] Open iOS app in Xcode
- [ ] Tap "Sign in with Google"
- [ ] Complete Google sign-in
- [ ] App receives token and shows onboarding
- [ ] Complete profile setup
- [ ] Dashboard shows (empty until calendar sync)
- [ ] Tap "Sync Calendar" button
- [ ] Meetings appear in list

## 📋 Next Steps After This Checklist

1. ✅ Complete Google OAuth setup (above)
2. 🚧 Build AI meeting prep feature
3. 🚧 Test full flow: meeting → AI prep → view prep
4. 🚧 Add Mac support
5. 🚧 Polish and launch

---

## Quick Reference

**Backend running?**
```bash
curl http://localhost:4000/health
# Should return: {"status":"ok",...}
```

**Google Setup Guide:**
See `/docs/google-api-setup.md` for detailed instructions

**Update .env:**
```bash
open -e /Users/ramikaawach/Desktop/Readi/.env
```

