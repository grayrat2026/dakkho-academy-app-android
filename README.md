# 📱 DAKKHO Academy — Flutter Android App

> Online learning platform for Bangladeshi polytechnic students.
> Built with Flutter 3.29, 100% Cloudflare backend, OneSignal push, zero Firebase dependency.

[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Workers-F38020?logo=cloudflare&logoColor=white)](https://workers.cloudflare.com)
[![OneSignal](https://img.shields.io/badge/Push-OneSignal-E54B4D?logo=onesignal&logoColor=white)](https://onesignal.com)
[![Build APK](https://img.shields.io/badge/Build-APK%20via%20CI-22C55E?logo=github&logoColor=white)](https://github.com/grayrat2026/dakkho-academy-app-android/actions)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## 📥 Download APK

### 3 Flavors Available

| Flavor | App ID | Use Case | Download |
|---|---|---|---|
| **dev** | `himadri.dakkho.pro.bd.dev` | Local development + debugging | [GitHub Actions](https://github.com/grayrat2026/dakkho-academy-app-android/actions) → Run workflow → `dev` |
| **staging** | `himadri.dakkho.pro.bd.staging` | Pre-release testing on real devices | [GitHub Actions](https://github.com/grayrat2026/dakkho-academy-app-android/actions) → Run workflow → `staging` |
| **prod** | `himadri.dakkho.pro.bd` | Play Store release | [GitHub Releases](https://github.com/grayrat2026/dakkho-academy-app-android/releases) |

### How to Build APK

**Option 1: GitHub Actions (recommended — no local setup needed)**

1. Go to: https://github.com/grayrat2026/dakkho-academy-app-android/actions
2. Click "Build Android APK" (left sidebar)
3. Click "Run workflow" button (top right)
4. Select flavor: `dev` / `staging` / `prod`
5. Click green "Run workflow"
6. Wait ~10 minutes
7. Click the completed run → scroll to **Artifacts** → download APK

**Option 2: Build locally**

```bash
git clone https://github.com/grayrat2026/dakkho-academy-app-android.git
cd dakkho-academy-app-android
flutter pub get
flutter gen-l10n

# Build APK (choose one flavor)
flutter build apk --flavor dev     --release --dart-define-from-file=.env.dev
flutter build apk --flavor staging --release --dart-define-from-file=.env.staging
flutter build apk --flavor prod    --release --dart-define-from-file=.env.prod

# Build AAB (for Play Store)
flutter build appbundle --flavor prod --release --dart-define-from-file=.env.prod
```

### Signing Key

| Item | Value |
|---|---|
| Keystore | `dakkho-release.jks` (in repo) |
| Store password | `Dakkho@2026` |
| Key password | `Dakkho@2026` |
| Key alias | `dakkho` |
| Validity | 10,000 days |

⚠️ **Keep this keystore safe!** If lost, you cannot update the app on Google Play.

---

## 📋 Table of Contents

- [Download APK](#-download-apk)
- [Overview](#overview)
- [Stack — Zero Firebase](#stack--zero-firebase)
- [Project Structure](#project-structure)
- [Build Flavors](#build-flavors)
- [Setup & Build](#setup--build)
- [Environment Variables](#environment-variables)
- [Theme System](#theme-system)
- [Anti-Piracy Architecture](#anti-piracy-architecture)
- [Backend API Contract](#backend-api-contract)
- [Micro-Animations](#micro-animations)
- [Permissions](#permissions)
- [Google Play Compliance](#google-play-compliance)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## Overview

This is the **Flutter Android port** of the DAKKHO Academy student app, originally built as a Next.js 16 SPA at [github.com/grayrat2026/dakkho-student-app](https://github.com/grayrat2026/dakkho-student-app).

**Package:** `himadri.dakkho.pro.bd`
**Min Android:** 7.0 (API 24)
**Target Android:** 15 (API 36)
**Flutter:** 3.29.3
**Kotlin:** 2.1.0
**Lines of code:** 22,000+
**Routes:** 97 (all with real implementations)
**Pages with real API:** 40+
**`flutter analyze`:** 0 errors, 0 warnings ✅

---

## Stack — Zero Firebase

| Concern | Solution |
|---|---|
| **Backend API** | Cloudflare Workers (Hono v4.7) |
| **Database** | Cloudflare D1 (SQLite) |
| **File Storage** | Cloudflare R2 (5 buckets) |
| **Cache / KV** | Cloudflare KV |
| **Edge CDN** | Cloudflare CDN |
| **Push Notifications** | OneSignal Flutter SDK (shared FCM — no Firebase project needed) |
| **Email** | Resend |
| **Payments** | PipraPay |
| **Live Classes** | LiveKit |
| **Error Tracking** | Sentry (optional) |
| **State Management** | Riverpod |
| **Routing** | go_router |
| **HTTP** | Dio + 5 interceptors |
| **Video** | media_kit (ExoPlayer) + youtube_player_flutter |
| **Local DB** | Hive + SharedPreferences + flutter_secure_storage |
| **Animations** | flutter_animate + Lottie |

---

## Project Structure

```
dakkho-academy-app-android/
├── .github/workflows/
│   ├── build-apk.yml          # CI: Build APK (dev/staging/prod)
│   └── build-aab.yml          # CI: Build AAB (Play Store)
├── android/
│   ├── app/
│   │   ├── build.gradle        # Flavors + signing + dependencies
│   │   ├── proguard-rules.pro  # R8 obfuscation
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/himadri/dakkho/pro/bd/
│   │       │   ├── MainActivity.kt       # FLAG_SECURE + MethodChannel
│   │       │   ├── DeviceUuidHelper.kt   # App-generated UUID in Keystore
│   │       │   ├── DeviceInfoHelper.kt
│   │       │   └── SecureWipeHelper.kt   # DoD 3-pass file wipe
│   │       └── res/                      # Icons, themes, XML configs
│   ├── key.properties          # Signing config
│   └── settings.gradle
├── dakkho-release.jks          # Signing keystore
├── lib/
│   ├── main.dart               # Entry point — OneSignal init
│   ├── app.dart                # MaterialApp.router
│   ├── core/
│   │   ├── theme/              # Colors, Typography, Theme (Light/Dark/System)
│   │   ├── router/             # go_router (97 routes)
│   │   ├── network/            # Dio client + 5 interceptors
│   │   ├── storage/            # SecureStorage (Keystore + SharedPreferences)
│   │   ├── notifications/      # OneSignalService
│   │   └── utils/
│   ├── data/
│   │   ├── api/                # 25 API clients (57+ endpoints)
│   │   ├── models/             # 16 data models
│   │   └── stores/             # 9 Riverpod stores
│   ├── features/               # 97 page implementations
│   │   ├── auth/               # Login, Signup, ForgotPassword
│   │   ├── home/               # HomePage (real API)
│   │   ├── explore/            # ExplorePage (real API)
│   │   ├── search/             # SearchPage (real API)
│   │   ├── course/             # Detail, Curriculum, Q&A, Notes, Quizzes, etc.
│   │   ├── video/              # UniversalVideoPlayer + VideoPlayerPage
│   │   ├── instructor/         # Profile, Courses, Reviews, Schedule, Contact
│   │   ├── profile/            # Edit, ChangePassword, LearningStats, etc.
│   │   ├── settings/           # 10 sub-pages (Account, Theme, Privacy, etc.)
│   │   ├── help/               # FAQ, Contact, Report, Legal pages
│   │   ├── exam/               # Prep, Schedule, Results, Practice, Tips
│   │   ├── social/             # Leaderboard, Community, Feedback, Roadmap
│   │   ├── departments/        # 20 department pages
│   │   ├── semesters/          # 8 semester pages
│   │   └── misc/               # Pricing, Changelog, Payment, etc.
│   ├── l10n/                   # English + Bengali localization
│   └── shared/                 # GlassCard, GradientButton, animations, AppShell
├── .env.dev / .env.staging / .env.prod
├── pubspec.yaml
├── l10n.yaml
├── PLAYSTORE.md                # Play Store submission guide
└── README.md
```

---

## Build Flavors

| Flavor | Application ID | API Base URL | Logging | Use Case |
|---|---|---|---|---|
| `dev` | `himadri.dakkho.pro.bd.dev` | `http://10.0.2.2:8787` | Verbose | Local dev against `wrangler dev` |
| `staging` | `himadri.dakkho.pro.bd.staging` | Production API | Verbose | Pre-release testing |
| `prod` | `himadri.dakkho.pro.bd` | Production API | Off | Play Store release |

---

## Anti-Piracy Architecture

5-layer anti-piracy — strongest possible for account sharing, zero DRM cost:

1. **Single-Device Login** — One account, one device. Force-logout on second login.
2. **Concurrent Stream Kill** — One video stream per account at a time.
3. **FLAG_SECURE** — Blocks screenshots + screen recording (Android native).
4. **AES-256-GCM Encryption** — Downloaded videos encrypted with device-bound keys.
5. **5-Minute HLS Tokens** — Short-lived, device-bound stream tokens.

---

## Theme System

3 modes: **Light**, **Dark**, **System** (default). User can toggle from Settings → Theme.

| Mode | Background | Glass Card |
|---|---|---|
| Light | `#F0F9FF` (sky-50) | White @ 70% + blur |
| Dark | `#0C1222` (custom navy) | Slate-800 @ 70% + blur |
| System | Follows phone | Adapts automatically |

---

## Roadmap

> ✅ **ALL 6 PHASES COMPLETE** — 97 routes, 40+ pages with real API, 0 errors, 0 warnings. Ready for Play Store submission.

| Phase | Weeks | Status |
|---|---|---|
| **Phase 0**: Backend triage (anti-piracy endpoints) | 1-2 | ✅ Deployed |
| **Phase 1**: Flutter scaffold | 3 | ✅ Complete |
| **Phase 2**: All 97 routes + real API integration | 4-5 | ✅ Complete |
| **Phase 3**: UniversalVideoPlayer + Course Detail + Curriculum | 6-9 | ✅ Complete |
| **Phase 4**: Instructor + Profile + Settings + Help sub-pages | 10-13 | ✅ Complete |
| **Phase 5**: Exam + Social + Misc + Payment verification | 14-16 | ✅ Complete |
| **Phase 6**: Localization + Play Store prep | 17-18 | ✅ Complete |

---

## Contributing

### Commit Convention
Format: `type: short description`
Types: `feat`, `fix`, `docs`, `refactor`, `chore`, `perf`

### Code Style
- `flutter analyze` must pass (zero errors)
- Use Riverpod for state, go_router for navigation
- Never use `withOpacity()` — use `withValues(alpha:)` instead
- Bengali strings use proper Unicode (no transliteration)
- No mock data in feature code

---

## License

Proprietary. © 2026 Himadri Shekhor Roy / DAKKHO Academy. All rights reserved.

---

## Links

- **Web app:** https://dakkho-student.pages.dev
- **Admin panel:** https://dakkho-admin.pages.dev
- **Instructor app:** https://dakkho-instructor.pages.dev
- **API:** https://dakkho-admin-api.dakkho-admin.workers.dev
- **GitHub Actions (build APK):** https://github.com/grayrat2026/dakkho-academy-app-android/actions
- **Releases:** https://github.com/grayrat2026/dakkho-academy-app-android/releases
