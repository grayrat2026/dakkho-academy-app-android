# 📱 DAKKHO Academy — Google Play Store Submission Guide

> Complete guide for submitting the DAKKHO Academy Android app to Google Play Store.

---

## App Information

| Field | Value |
|---|---|
| **App Name** | DAKKHO Academy |
| **Package ID** | `himadri.dakkho.pro.bd` |
| **Developer Name** | Himadri Shekhor Roy |
| **Developer Email** | himadrient@proton.me |
| **Category** | Education |
| **Content Rating** | Teen (16+) |
| **Target Audience** | Teen (16-20) — polytechnic students |
| **Pricing** | Free (in-app purchases via PipraPay) |

---

## Store Listing

### Short Description (80 chars max)
```
Polytechnic learning app: courses, video lectures, quizzes & exam prep for BD students.
```

### Full Description (4000 chars max)
```
🎓 DAKKHO Academy — বাংলাদেশের পলিটেকনিক শিক্ষার্থীদের জন্য সম্পূর্ণ লার্নিং প্ল্যাটফর্ম

DAKKHO Academy is the ultimate learning companion for polytechnic students in Bangladesh. Access high-quality video courses, practice quizzes, study materials, and live classes — all in one app.

📚 WHAT YOU GET:
• 80+ courses across 20 polytechnic departments (CSE, ETE, EEE, ME, CE, and more)
• HD video lectures with Bengali + English support
• Download videos for offline study (encrypted, 30-day access)
• Practice MCQ quizzes with instant explanations
• Course curriculum organized by Subject → Class → Unit → Lesson
• Live class sessions with instructors
• Track your progress with detailed analytics
• Earn certificates upon course completion
• Compete on the leaderboard with fellow students

🛡️ ANTI-PIRACY PROTECTION:
• Single-device login — your account stays secure
• Encrypted downloads (AES-256-GCM)
• Screenshot protection (FLAG_SECURE)
• No account sharing possible

💳 AFFORDABLE PRICING:
• Free preview videos for every course
• Pay per course via bKash, Nagad, Rocket (PipraPay)
• Coupon codes for discounts
• 7-day money-back guarantee

🎨 BEAUTIFUL UI:
• Glassmorphism dark theme (Light/Dark/System modes)
• Smooth 60fps animations
• Material 3 design
• Bengali + English interface
• Optimized for low-end Android devices

🔧 TECHNICAL DETAILS:
• Minimum Android 7.0 (API 24)
• App size: ~10 MB
• Works on 2G/3G/4G/Wi-Fi
• Offline mode for downloaded videos
• Push notifications via OneSignal

📊 SUBJECTS COVERED:
• Computer Science & Engineering (CSE)
• Electronics & Telecommunication (ETE)
• Electrical Engineering (EEE)
• Mechanical Engineering (ME)
• Civil Engineering (CE)
• Architecture, Textile, Chemical, Automobile
• And 14 more polytechnic departments!

📖 FEATURES IN DETAIL:
• Universal Video Player: HLS streaming + YouTube + MP4 support
• Smart Curriculum: Subject > Class > Unit > Lesson hierarchy
• Lecture Sheets: PDF resources for each lesson
• Q&A Forum: Ask questions and get answers
• Personal Notes: Color-coded sticky notes per course
• Quiz Runner: MCQ with explanations and scoring
• Watch History: Resume from where you left off
• Bookmarks: Save courses and videos for later
• Achievements: Unlock badges and earn XP
• Referral Program: Invite friends and earn credit

DAKKHO Academy — শিখুন, এগিয়ে যান, সফল হোন।

Download now and start your polytechnic learning journey!
```

### Keywords (for ASO)
```
polytechnic, diploma, engineering, bteb, bangladesh education,
dakkho, course, video lecture, exam prep, quiz, cse, eee,
bengali learning app, online course bd, study app
```

---

## Screenshots (Required: 2-8)

### Phone Screenshots (16:9 or 9:16, min 320px, max 3840px)

| # | Screen | Description |
|---|---|---|
| 1 | Home Page | Hero welcome card + trending courses + department chips |
| 2 | Course Detail | Course thumbnail + tabs + enroll button |
| 3 | Video Player | Playing video with controls visible + episode panel |
| 4 | Curriculum | Subject > Class > Unit > Lesson tree expanded |
| 5 | Quiz Runner | MCQ question with 4 options + progress bar |
| 6 | Leaderboard | Top 3 podium + user rank highlighted |
| 7 | Achievements | Badge grid with unlocked/locked states |
| 8 | Settings > Theme | Light/Dark/System toggle with live preview |

### Feature Graphic (1024 x 500)

```
Background: Glassmorphism dark gradient (#0C1222 → #0F172A)
Center: DAKKHO Academy logo (graduation cap icon)
Tagline: "পলিটেকনিক শিক্ষার সম্পূর্ণ সমাধান"
Bottom: Department icons (CSE, ETE, EEE, ME, CE) in a row
```

### App Icon (512 x 512)
Already generated at `download/app-icons/ic_launcher-playstore-512.png`

---

## Privacy Policy URL

**Required:** Must be a publicly accessible URL (not in-app).

Host at: `https://dakkho.pro.bd/privacy`

Content: The full Privacy Policy from `lib/features/help/legal_pages.dart` (PrivacyPolicyPage class).

---

## Data Safety Form

### Data Collected

| Data Type | Purpose | Encrypted | Shared |
|---|---|---|---|
| Email address | Account registration | ✅ | ❌ |
| Name | Profile | ✅ | ❌ |
| Course progress | Learning analytics | ✅ | ❌ |
| Device ID (app-generated UUID) | Anti-piracy | ✅ | ❌ |
| OneSignal player ID | Push notifications | ✅ | ❌ |
| Payment transaction ID | Payment verification | ✅ | PipraPay only |

### Data NOT Collected
- ❌ Location
- ❌ Camera photos
- ❌ Contacts
- ❌ SMS
- ❌ Call logs
- ❌ Microphone
- ❌ Health data
- ❌ Financial info (card numbers — processed by PipraPay, not stored)

### Data Handling
- Data is encrypted in transit (HTTPS)
- Data is encrypted at rest (Cloudflare D1 + R2)
- Users can request data deletion anytime
- Users can request data export (JSON)
- No data is sold to third parties

---

## App Content Rating (IARC Questionnaire)

| Question | Answer |
|---|---|
| App contains cartoon violence? | No |
| App contains realistic violence? | No |
| App contains sexual content? | No |
| App contains profanity? | No |
| App contains user-generated content? | Yes (Q&A, community posts) |
| App allows digital purchases? | Yes (course enrollment) |
| App shares user location? | No |
| App targeted to children? | No (targeted to 16+ polytechnic students) |

**Expected Rating:** Everyone 10+ (or Teen)

---

## App Permissions (declared in Play Console)

| Permission | Justification (shown to users) |
|---|---|
| INTERNET | Stream course videos and fetch content |
| ACCESS_NETWORK_STATE | Detect network quality for adaptive streaming |
| POST_NOTIFICATIONS | Receive study reminders and live class alerts |
| FOREGROUND_SERVICE | Keep video downloads running in background |
| WAKE_LOCK | Prevent sleep during video playback |
| RECEIVE_BOOT_COMPLETED | Resume interrupted downloads after restart |
| WRITE_EXTERNAL_STORAGE (max SDK 28) | Save downloads on Android 9 and below |
| VIBRATE | Haptic feedback for micro-animations |

---

## Target Audience

| Field | Value |
|---|---|
| Target age group | 16-20 (Teen) |
| Primary country | Bangladesh |
| Primary language | English (Bengali supported) |
| App appeal | Teens + Adults |

---

## Build & Upload

### Generate Release AAB

```bash
cd dakkho-academy-app-android

# Get dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Generate launcher icons
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create

# Build release AAB
flutter build appbundle \
  --flavor prod \
  --release \
  --dart-define-from-file=.env.prod

# Output: build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### Upload to Play Console

1. Go to https://play.google.com/console
2. Create new app → fill in app name, language, app type
3. Upload AAB to Production track
4. Fill in Store Listing (use text above)
5. Complete Data Safety form
6. Complete Content Rating questionnaire
7. Set Target Audience
8. Submit for review

### Staged Rollout

| Stage | Percentage | Duration |
|---|---|---|
| 1 | 10% | 3 days — monitor crash reports |
| 2 | 50% | 3 days — monitor support tickets |
| 3 | 100% | Permanent |

---

## Signing Key

**IMPORTANT:** Generate a release keystore before first upload. Play Store requires app signing.

```bash
keytool -genkey -v -keystore dakkho-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias dakkho
```

Store the keystore + passwords securely. If lost, you CANNOT update the app.

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=dakkho
storeFile=/path/to/dakkho-release.jks
```

Update `android/app/build.gradle` signingConfig to use this keystore for release builds.

---

## Post-Launch Checklist

- [ ] Monitor crash reports (Play Console → Android Vitals)
- [ ] Monitor ANR rate (must be < 0.47%)
- [ ] Respond to user reviews within 24h
- [ ] Push regular updates (at least monthly)
- [ ] Keep `app_min_version` in `/api/config` updated
- [ ] Monitor PipraPay webhook delivery
- [ ] Check OneSignal notification delivery rate
- [ ] Review server costs (Cloudflare Workers + D1 + R2)

---

## Contact

- **Developer:** Himadri Shekhor Roy
- **Email:** himadrient@proton.me
- **Support:** support@dakkho.pro.bd
- **Website:** https://dakkho.pro.bd
