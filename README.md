# 📱 DAKKHO Academy — Flutter Android App

> Online learning platform for Bangladeshi polytechnic students.
> Built with Flutter 3.27, 100% Cloudflare backend, OneSignal push, zero Firebase dependency.

[![Flutter](https://img.shields.io/badge/Flutter-3.27.4-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Workers-F38020?logo=cloudflare&logoColor=white)](https://workers.cloudflare.com)
[![OneSignal](https://img.shields.io/badge/Push-OneSignal-E54B4D?logo=onesignal&logoColor=white)](https://onesignal.com)

---

## 📋 Table of Contents

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

The web app's tech health was 3.5/10 (mock data shipped as real, fake leaderboards, broken search, payment cache invalidation missing, etc.). Rather than wrap the broken web app in Capacitor, we're rebuilding it as a true native Flutter app for:

- Native 60fps animations (no webview jank)
- Real anti-piracy (FLAG_SECURE, Keystore-bound encryption, single-device login)
- Proper Material 3 design
- iOS-ready architecture (if we ever ship iOS)
- Cleaner codebase, no inherited tech debt

**Package:** `himadri.dakkho.pro.bd`
**Min Android:** 7.0 (API 24) — covers 98% of BD students
**Target Android:** 15 (API 35) — Play Store compliance

---

## Stack — Zero Firebase

This project intentionally avoids Firebase. Everything runs on Cloudflare + OneSignal + your existing infrastructure.

| Concern | Solution | Why |
|---|---|---|
| **Backend API** | Cloudflare Workers (Hono v4.7) | Already in production |
| **Database** | Cloudflare D1 (SQLite) | Already in production |
| **File Storage** | Cloudflare R2 | Already in production (5 buckets) |
| **Cache / KV** | Cloudflare KV | Already in production |
| **Edge CDN** | Cloudflare CDN | Free, unlimited |
| **Push Notifications** | **OneSignal Flutter SDK** | Uses OneSignal's shared FCM project — no `google-services.json` needed |
| **Email** | Resend | Already integrated in worker |
| **Payments** | PipraPay | BD-friendly gateway |
| **Live Classes** | LiveKit | Already integrated in worker |
| **Error Tracking** | Sentry (optional) | Or use Cloudflare Workers logs only |
| **State Management** | Riverpod | Modern, type-safe, testable |
| **Routing** | go_router | Declarative, deep-link friendly |
| **HTTP** | Dio + interceptors | Auth, retry, force-logout all in interceptors |
| **Video** | media_kit (ExoPlayer) + youtube_player_flutter | HLS + MP4 + YouTube in one widget |
| **Local DB** | Hive + SharedPreferences + flutter_secure_storage | Tiered: encrypted → fast → memory |
| **Animations** | flutter_animate + Lottie + Rive | "Millions of micro-animations" |

### Why OneSignal without Firebase?

OneSignal's Android SDK uses FCM as the underlying transport. But OneSignal provides a **shared Firebase project** — you just sign up at OneSignal, get an app ID, and the SDK handles FCM transport behind the scenes. No `google-services.json`, no Firebase project of your own, no Google Services Gradle plugin.

This is the same approach the web app uses (CDN-loaded OneSignal SDK with just `app_id: 'ba6c42b2-...'`).

---

## Project Structure

```
dakkho-academy-app-android/
├── android/                              # Native Android shell
│   └── app/
│       ├── build.gradle                  # Flavors (dev/staging/prod) + permissions + ProGuard
│       ├── proguard-rules.pro            # R8 obfuscation rules
│       └── src/main/
│           ├── AndroidManifest.xml       # Permissions + deep links + OneSignal metadata
│           ├── kotlin/himadri/dakkho/pro/bd/
│           │   ├── MainActivity.kt       # FLAG_SECURE + MethodChannel
│           │   ├── DeviceUuidHelper.kt   # App-generated UUID in Keystore (NOT ANDROID_ID)
│           │   ├── DeviceInfoHelper.kt   # Returns Build.MODEL / Android version etc.
│           │   └── SecureWipeHelper.kt   # DoD 3-pass file wipe for downloaded videos
│           └── res/
│               ├── values/colors.xml     # DAKKHO brand colors
│               ├── values/styles.xml     # Dark themes
│               ├── drawable/             # Adaptive icon foreground/background, splash logo
│               ├── mipmap-*/             # Launcher icons (all 5 densities)
│               ├── mipmap-anydpi-v26/    # Adaptive icon XML
│               └── xml/
│                   ├── backup_rules.xml           # Disable backup for tokens/downloads
│                   ├── data_extraction_rules.xml  # Android 12+ backup rules
│                   ├── network_security_config.xml # HTTPS-only + localhost exception
│                   └── file_paths.xml              # FileProvider paths
├── assets/
│   ├── icons/                            # Source SVG + 512px PNG
│   ├── images/                           # (empty — add as needed)
│   ├── lottie/                           # Lottie JSON animations
│   └── fonts/                            # Inter + NotoSansBengali (add TTFs)
├── lib/
│   ├── main.dart                         # Entry point — OneSignal init
│   ├── app.dart                          # MaterialApp.router root
│   ├── core/
│   │   ├── theme/
│   │   │   ├── colors.dart               # Matches Tailwind vars from web app
│   │   │   ├── typography.dart           # Inter + NotoSansBengali fallback
│   │   │   ├── theme.dart                # Dark + Light ThemeData
│   │   │   └── dakkho_theme.dart         # Barrel file
│   │   ├── router/
│   │   │   └── app_router.dart           # go_router with auth redirect
│   │   ├── network/
│   │   │   └── dio_client.dart           # Dio + 5 interceptors (Auth/Device/ForceLogout/Retry/Log)
│   │   ├── storage/
│   │   │   └── secure_storage.dart       # FlutterSecureStorage + SharedPreferences
│   │   ├── notifications/
│   │   │   └── onesignal_service.dart    # OneSignal init + permission + tags
│   │   ├── utils/
│   │   │   └── platform_info.dart        # device_info_plus + package_info_plus
│   │   └── constants/                    # (empty — add as needed)
│   ├── data/
│   │   ├── api/
│   │   │   ├── auth_api.dart             # /api/auth/* client
│   │   │   ├── device_api.dart           # /api/device/* client (single-device login)
│   │   │   └── stream_api.dart           # /api/stream/* client (concurrent stream kill)
│   │   ├── models/                       # (empty — Freezed models in Phase 2)
│   │   └── stores/
│   │       ├── auth_store.dart           # AuthState (port of useAuthStore)
│   │       ├── device_store.dart         # DeviceState (new — anti-piracy)
│   │       └── theme_store.dart          # ThemeState (light/dark/system)
│   ├── features/
│   │   ├── auth/                         # LoginPage, SignupPage, ForgotPasswordPage
│   │   ├── home/                         # HomePage (with shimmer skeletons)
│   │   ├── explore/                      # ExplorePage (stub — Phase 3)
│   │   ├── search/                       # SearchPage (stub — Phase 3)
│   │   ├── notifications/                # NotificationsPage (stub — Phase 9)
│   │   ├── profile/                      # ProfilePage (with logout)
│   │   ├── course/                       # CourseDetailPage (stub — Phase 4)
│   │   ├── video/                        # VideoPlayerPage (stub — Phase 5)
│   │   ├── payment/                      # (empty — Phase 4)
│   │   ├── downloads/                    # DownloadsPage (stub — Phase 7)
│   │   ├── device/                       # DeviceSettingsPage (Switch Device UI)
│   │   ├── settings/                     # SettingsPage (stub — Phase 8)
│   │   └── error/                        # NotFoundPage
│   └── shared/
│       ├── animations/
│       │   └── dakkho_animations.dart    # 7-layer animation framework
│       ├── layouts/
│       │   └── app_shell.dart            # TopBar + Drawer + BottomNav
│       └── widgets/
│           ├── glass_card.dart           # Glassmorphism card (BackdropFilter blur)
│           ├── gradient_button.dart      # Primary CTA with loading state
│           ├── loading_skeleton.dart     # Shimmer placeholders
│           ├── empty_state.dart          # Friendly empty illustrations
│           └── widgets.dart              # Barrel file
├── .env                                  # Default env (editor autocomplete)
├── .env.dev                              # Dev flavor
├── .env.staging                          # Staging flavor
├── .env.prod                             # Production flavor
├── pubspec.yaml                          # 28 dependencies (no Firebase)
├── analysis_options.yaml                 # Lint rules
└── README.md                             # This file
```

---

## Build Flavors

Three flavors let you install dev, staging, and prod side-by-side on the same phone.

| Flavor | Application ID | API Base URL | Logging | Use Case |
|---|---|---|---|---|
| `dev` | `himadri.dakkho.pro.bd.dev` | `http://10.0.2.2:8787` | Verbose | Local dev against `wrangler dev` |
| `staging` | `himadri.dakkho.pro.bd.staging` | `https://dakkho-admin-api.dakkho-admin.workers.dev` | Verbose | Pre-release testing |
| `prod` | `himadri.dakkho.pro.bd` | `https://dakkho-admin-api.dakkho-admin.workers.dev` | Off | Play Store release |

App labels:
- dev → "DAKKHO Dev"
- staging → "DAKKHO Staging"
- prod → "DAKKHO Academy"

---

## Setup & Build

### Prerequisites

- **Flutter 3.27.4+** (`flutter --version`)
- **Android Studio** (or Android SDK Command-Line Tools)
- **Java 17** (OpenJDK 17 — Android Studio Hedgehog+ bundles this)
- **An Android device or emulator** with Android 7.0+ (API 24+)

### First-time Setup

```bash
# 1. Clone
git clone https://github.com/grayrat2026/dakkho-academy-app-android.git
cd dakkho-academy-app-android

# 2. Install dependencies
flutter pub get

# 3. (Optional) Generate launcher icons + splash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### Run (Dev)

```bash
# Run dev flavor against local wrangler dev server (start worker first)
cd /path/to/dakkho-worker/worker
npx wrangler dev --port 8787

# In another terminal, run Flutter dev flavor
flutter run --flavor dev --dart-define-from-file=.env.dev
```

### Run (Staging)

```bash
flutter run --flavor staging --dart-define-from-file=.env.staging
```

### Run (Production)

```bash
flutter run --flavor prod --dart-define-from-file=.env.prod
```

### Build APK (for direct distribution)

```bash
flutter build apk --flavor prod --release --dart-define-from-file=.env.prod
# Output: build/app/outputs/flutter-apk/app-prod-release.apk
```

### Build AAB (for Play Store)

```bash
flutter build appbundle --flavor prod --release --dart-define-from-file=.env.prod
# Output: build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### Analyze Code

```bash
flutter analyze
# Expected: "No issues found!"
```

---

## Environment Variables

All env vars are passed via `--dart-define-from-file=<file>`. They're read in Dart via `String.fromEnvironment(...)`.

| Variable | Default | Description |
|---|---|---|
| `API_BASE_URL` | (required) | Cloudflare Worker URL |
| `CDN_BASE_URL` | (required) | Cloudflare Pages URL (for static assets) |
| `DEEP_LINK_SCHEME` | `dakkho` | URL scheme for deep links (`dakkho://...`) |
| `PIPRAPAY_BASE_URL` | (required) | PipraPay checkout base URL |
| `APP_FLAVOR` | (required) | `dev` \| `staging` \| `prod` |
| `APP_VERSION` | `1.0.0+1` | App version sent in headers |
| `ONESIGNAL_APP_ID` | (required) | OneSignal app ID (same as web app) |
| `SENTRY_DSN` | (empty) | Sentry DSN for error tracking (optional) |
| `ENABLE_DEV_LOGGING` | `false` | Verbose Dio HTTP logging in console |
| `ENABLE_MOCK_DATA` | `false` | Show mock data stubs (always false in prod) |

---

## Theme System

Three theme modes — Light, Dark, System. User can toggle from Settings (Phase 8).

### Default: System

The app respects the user's system theme on first launch. If their phone is in dark mode, DAKKHO opens in dark mode.

### Color Palette (matches web app)

| Token | Dark Mode | Light Mode | Tailwind Equivalent |
|---|---|---|---|
| `background` | `#0C1222` | `#F0F9FF` | (custom dark navy / sky-50) |
| `surface` | `#0F172A` | `#FFFFFF` | slate-900 |
| `surfaceLight` | `#1E293B` | `#F1F5F9` | slate-800 |
| `primary` | `#0EA5E9` | `#0EA5E9` | sky-500 |
| `accent` | `#10B981` | `#10B981` | emerald-500 |
| `textPrimary` | `#F0F9FF` | `#0F172A` | sky-50 / slate-900 |
| `textSecondary` | `#94A3B8` | `#64748B` | slate-400 / slate-500 |

### Glassmorphism

`GlassCard` widget uses `BackdropFilter` (GPU-accelerated on Android) for the blur effect. Matches the web app's `.glass-card` CSS:

```dart
GlassCard(
  padding: const EdgeInsets.all(16),
  child: Text('Hello'),
)
```

### Typography

- **Latin text:** Inter (modern, clean)
- **Bengali text:** NotoSansBengali (auto-fallback via `fontFamilyFallback`)
- **Monospace:** RobotoMono (for UUIDs, IDs)

---

## Anti-Piracy Architecture

5-layer anti-piracy — strongest possible for account sharing, zero DRM cost.

### Layer 1: Single-Device Login (NEW — stronger than original spec)

One student account can be logged in on **exactly one device at a time**. If a second device logs in, the first device is force-logged out on its next heartbeat.

**How it works:**
1. Device A logs in → calls `POST /api/device/bind` → server marks A as active
2. Device B logs in → calls `POST /api/device/bind` → server marks A as inactive + writes `force_logout_signal`
3. Device A's next `POST /api/device/verify` (within 5 min) returns `{forceLogout: true}`
4. Flutter's `ForceLogoutInterceptor` triggers `AuthNotifier.forceLogout()` which wipes:
   - Auth token (FlutterSecureStorage)
   - User object (SharedPreferences)
   - Device UUID (FlutterSecureStorage)
   - Downloaded `.enc` videos (Phase 7)
   - Keystore keys (`dakkho_dl_*`) (Phase 7)
   - Hive cache boxes (Phase 3)
5. User sees "আপনার account অন্য ডিভাইসে login করা হয়েছে" screen
6. Flutter calls `POST /api/device/ack-force-logout` → server deletes the signal
7. User redirected to login screen

**Why stronger than original spec?**
Original spec only killed concurrent video streams. Single-device login kills the entire session — account sharing becomes impossible, not just inconvenient.

### Layer 2: Concurrent Stream Kill

Within the single logged-in device, only ONE video can stream at a time. Prevents PiP + main player abuse, or rooted devices with split-screen.

- `POST /api/stream/start` — kills any existing active stream for same video on different device
- `POST /api/stream/heartbeat` — 30s interval, returns `{killed: true}` if displaced
- `POST /api/stream/end` — clean shutdown
- `POST /api/stream/token-refresh` — 5-min TTL, refuses if heartbeat stale

### Layer 3: FLAG_SECURE (Android Native)

`MainActivity.kt` sets `WindowManager.LayoutParams.FLAG_SECURE` on `onCreate` and re-applies on `onWindowFocusChanged` (some OEMs strip it on focus changes).

**Blocks:**
- Android screenshot (Power + Volume Down)
- `adb screencap`
- AZ Screen Recorder and similar apps
- Built-in screen recorder (Android 14+)

**Doesn't block:**
- Physical camera pointed at screen (addressed by forensic watermark — Phase 5)

### Layer 4: AES-256-GCM Download Encryption (Phase 7)

Downloaded videos encrypted with hardware-bound Keystore keys. File can't be played on another device even if copied.

### Layer 5: Short-Lived HLS Tokens

5-minute token TTL (down from 30 min). Token bound to `videoId + sessionId + userId + deviceUuid`. Auto-refresh every 4.5 min.

---

## Backend API Contract

The Flutter app calls the following endpoints. All are deployed in `dakkho-worker` (Phase 0 PRs #1 and #2).

### Existing Endpoints (no changes)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/auth/login` | POST | Login with email + password |
| `/api/auth/signup` | POST | Signup (sends OTP) |
| `/api/auth/verify-otp` | POST | Verify OTP, returns token |
| `/api/auth/resend-otp` | POST | Resend OTP |
| `/api/auth/forgot-password` | POST | Send reset OTP |
| `/api/auth/reset-password` | POST | Reset password with OTP |
| `/api/auth/logout` | POST | Invalidate session |
| `/api/auth/me` | GET | Get current user |
| `/api/courses` | GET | List courses |
| `/api/courses/:id` | GET | Course detail |
| `/api/courses/:id/videos` | GET | Course videos |
| `/api/enrollments/mine` | GET | My enrollments |
| `/api/enrollments/check` | GET | Check enrollment |
| `/api/enroll` | POST | Enroll in free course |
| `/api/payments/create` | POST | Create PipraPay payment |
| `/api/payments/verify` | GET | Verify payment status |
| `/api/notifications` | GET | List notifications |
| `/api/notifications/:id/read` | POST | Mark as read |
| `/api/notifications/read-all` | POST | Mark all as read |
| `/api/push/register` | POST | Register OneSignal player_id |
| `/api/push/unregister` | POST | Unregister push token |
| `/api/profile/stats` | GET | Profile stats |
| `/api/leaderboard` | GET | Leaderboard |
| `/api/achievements` | GET | Achievements |

### New Endpoints (from Phase 0 PRs)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/device/bind` | POST | Bind device after login (kicks prior active device) |
| `/api/device/verify` | POST | Heartbeat (cold start + every 5min) |
| `/api/device/status` | GET | Settings page UI |
| `/api/device/switch` | POST | Self-service Switch Device (7-day cooldown) |
| `/api/device/ack-force-logout` | POST | Ack force-logout after wipe |
| `/api/stream/start` | POST | Start streaming (kills concurrent streams) |
| `/api/stream/heartbeat` | POST | 30s keep-alive |
| `/api/stream/end` | POST | Clean shutdown |
| `/api/stream/token-refresh` | POST | Renew 5-min token |
| `/api/stream/active` | GET | Currently active stream |

### Required Headers

| Header | Value | Purpose |
|---|---|---|
| `Authorization` | `Bearer <token>` | Auth (auto-injected by Dio interceptor) |
| `X-Device-UUID` | UUID v4 | Device identifier (auto-injected) |
| `X-App-Version` | `1.0.0+1` | App version (for force-update check) |
| `X-App-Flavor` | `dev` \| `staging` \| `prod` | Build flavor |
| `X-Platform` | `android` | Platform identifier |

---

## Micro-Animations

"Millions of Micro Animations" — 7-layer animation framework on every screen.

### 7 Layers

1. **Press feedback** — scale 0.96 + opacity 0.85 on tap (80ms)
2. **Hover/glow** — cards lift 2dp + shadow grows (mouse only)
3. **Entrance** — staggered fade+slide for list items (50ms/item, capped at 8)
4. **Page transition** — fade-through (Material 3) + parallax Hero
5. **State change** — toggle spring, loading → success morph
6. **Scroll** — app bar collapse, FAB scale, pull-to-refresh spinner
7. **Micro-delight** — confetti, trophy bounce, ripple bookmark

### Specific Animations

50+ baked into the design system. Notable ones:

- GlassCard: hover lift + shadow glow + press scale
- GradientButton: press scale + glow + loading morph
- Bookmark tap: heart icon bursts with 8 particles + haptic
- Course progress: animated gradient shimmer
- OTP input: each digit pops with scale 1.2 → 1.0 on entry
- Toast: slides from top with bounce, auto-dismiss with fade-down
- Live class: pulsing red dot with expanding ring
- Leaderboard rank up: number flips like departure board
- Achievement unlock: Lottie celebration + haptic medium impact
- Payment success: confetti burst + checkmark morph
- Force-logout: red flash + screen wipe (memorable UX)
- Network offline/online: banner slides with pulse

### Tech

- `flutter_animate` for declarative chains (`.animate().fadeIn().slideX()`)
- `Lottie` for complex illustrations
- `Rive` for interactive state-machine animations
- `CustomPainter` for particle effects

### Accessibility

All animations respect "Reduce motion" accessibility setting. If user enables it in Settings, animations are reduced to instant fades.

---

## Permissions

7 Android permissions, all with Play-Store-required justifications.

| Permission | Why |
|---|---|
| `INTERNET` | Stream course videos + fetch course content from Cloudflare API |
| `ACCESS_NETWORK_STATE` | Detect network quality for adaptive video streaming |
| `POST_NOTIFICATIONS` (Android 13+) | Receive study reminders, new course announcements, live class alerts via OneSignal |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_DATA_SYNC` | Keeps video downloads running when app is backgrounded |
| `WAKE_LOCK` | Prevents sleep during video playback and downloads |
| `RECEIVE_BOOT_COMPLETED` | Resumes interrupted downloads after device restart |
| `WRITE_EXTERNAL_STORAGE` (max SDK 28) | Saves downloaded videos on Android 9 and below (newer versions use scoped storage) |
| `VIBRATE` | Haptic feedback for micro-animations |

**No SMS, contacts, location, camera, microphone, phone state, or storage above SDK 28.**

---

## Google Play Compliance

### Data Safety Form (declared)

| Data collected | Purpose | Encrypted in transit | Encrypted at rest |
|---|---|---|---|
| Email | Account | ✅ (HTTPS) | ✅ (Keystore) |
| Name | Profile | ✅ | ✅ |
| Course progress | Learning analytics | ✅ | ✅ |
| Device ID (app-generated UUID) | Anti-piracy | ✅ | ✅ (Keystore) |
| OneSignal player_id | Push notifications | ✅ | ✅ |

**Data is not sold. Data is not shared with third parties.**

### Privacy Policy

Required: public URL at `dakkho.pro.bd/privacy` (must be accessible without app login).

### Target Audience

"Teen" (16-20) — Bangladeshi polytechnic students.

### Account Deletion

Required by Play Store policy. Implemented at `/profile/delete-account` — calls `/api/auth/delete-account` which purges user data per BD privacy law.

### Content Rating

IARC questionnaire — likely "Everyone" or "Teen".

---

## Roadmap

> **Phase 2 Update:** All 97 routes from the web app are now in Flutter. 12 high-traffic pages have real Cloudflare API integration (Home, Explore, Search, MyCourses, Notifications, Leaderboard, Achievements, WatchHistory, LiveSessions, Instructors, ThemeSettings, Settings). Remaining pages have proper structure with real API clients ready to be wired in.

| Phase | Weeks | Status |
|---|---|---|
| **Phase 0**: Backend triage (anti-piracy endpoints) | 1-2 | ✅ Deployed |
| **Phase 1**: Flutter scaffold (theme, router, stores, API client, animations) | 3 | ✅ Complete |
| **Phase 2**: All 97 routes + real API integration for 12 high-traffic pages | 4-5 | ✅ Complete |
| **Phase 3**: Course detail + checkout + video player + remaining pages polish | 6-9 | 🔄 Next |
| **Phase 3**: Core pages (Home, Explore, Search, My Courses, Notifications, Profile) with REAL API | 6-7 | Pending |
| **Phase 4**: Course detail + checkout + PipraPay + payment cache invalidation | 8-9 | Pending |
| **Phase 5**: UnifiedVideoPlayer (HLS + YouTube + MP4) + watch progress + forensic watermark | 10 | Pending |
| **Phase 6**: Anti-piracy UI (device binding, switch device, StreamKickedOverlay, DeviceMismatchScreen) | 11 | Pending |
| **Phase 7**: Encrypted downloads (AES-256-GCM + Keystore + 30-day TTL + secure wipe) | 12-13 | Pending |
| **Phase 8**: Remaining 60+ pages (settings, help, profile sub-pages, departments, semesters, exam, social, misc) | 14-16 | Pending |
| **Phase 9**: Push (OneSignal), deep links, root detection, cert pinning, R8, Play Store submission | 17-18 | Pending |

**Total: 18 weeks**

---

## Contributing

### Commit Convention

Format: `type: short description`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

Example: `feat: add 4-step signup wizard with OTP verification`

### Branch Convention

- `main` — production-ready
- `feat/<name>` — feature branches
- `fix/<name>` — bug fix branches

### Code Style

- `flutter analyze` must pass (zero issues)
- Use Riverpod `StateNotifierProvider` for state
- Use `Freezed` for immutable data models
- Use `go_router` for navigation (no Navigator.push)
- Never use `withOpacity()` — use `withValues(alpha:)` instead (Flutter 3.27+)
- Bengali strings use proper Unicode (no transliteration)

### Mock Data Policy

**NO MOCK DATA in feature code.**

If a feature genuinely needs mock data during development (e.g. backend endpoint not built yet):

1. Place mock files in `lib/data/mock/`
2. Add header comment: `// ⚠️ MOCK DATA — REMOVE BEFORE PRODUCTION`
3. Only load when `kDebugMode && APP_FLAVOR == 'dev'`
4. Include a `README.md` in `lib/data/mock/` with 1-command removal script

---

## License

Proprietary. © 2026 Himadri / DAKKHO Academy. All rights reserved.

---

## Links

- **Web app:** https://dakkho-student.pages.dev
- **Admin panel:** https://dakkho-admin.pages.dev
- **Instructor app:** https://dakkho-instructor.pages.dev
- **API:** https://dakkho-admin-api.dakkho-admin.workers.dev
- **Web app repo:** https://github.com/grayrat2026/dakkho-student-app
- **Worker repo:** https://github.com/grayrat2026/dakkho-worker
- **This app:** https://github.com/grayrat2026/dakkho-academy-app-android
