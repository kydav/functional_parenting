# Functional Parenting

A cross-platform (mobile-first) coaching app for the **Functional Parenting** framework —
helping parents build stronger relationships and respond to behavior functionally.
Flutter + Riverpod + go_router + Firebase, matching the house stack.

## Status — MVP scaffold

Free tier is fully navigable (runs in **demo mode** without Firebase configured):

| Area | Route | Notes |
|------|-------|-------|
| Today | `/today` | Daily tip, challenge, reflection, Reset button, "What should I do?" shortcut |
| Reset Right Now | `/reset` | Full-screen guided breathing / grounding |
| Learn | `/learn` | Framework intro + four pillars (course teaser = Pro) |
| Tools | `/tools` | Decision tool, scripts, behavior check (free); toolkit items gated Pro |
| — What should I do? | `/tools/decide` | Branching in-the-moment guidance |
| — Scripts | `/tools/scripts` | Ready-to-use phrases with the "why" |
| — Behavior check | `/tools/assessment` | Single free function-mapping quiz |
| Workshops | `/workshops` | Advertise workshops + book a free call |
| Profile | `/profile` | Account, notifications, upgrade/paywall placeholder |

### Brand
- Palette in `lib/core/theme/app_theme.dart`: navy `#0A0F2C`, light blue `#B1CDD9`,
  sage/cream `#E3DFB7`, near-white bg `#F4F5F8`.
- Fonts via `google_fonts`: **Raleway** (headings), **Poppins** (body).

## Architecture
Feature-first, mirroring the other apps in this workspace:
```
lib/
  core/
    models/         content value types
    providers/      auth, content (seed data -> swap for Firestore later)
    presentation/   app_shell (responsive sidebar / floating nav), shared widgets
    router/         go_router with auth redirect
    services/       firebase_bootstrap
    theme/
  features/<name>/presentation/
```

Seed content lives in `lib/core/providers/content_provider.dart`. The providers are the
seam: point them at Firestore without touching the UI.

## Running

```bash
flutter pub get
flutter run           # runs in demo mode; any email/password signs in
```

Min iOS deployment target is **15.0** (required by Firebase).

### Firebase config (kept out of the repo)
`flutterfire configure` has been run locally. The generated config is
**gitignored** — it never lands in the repo:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json` / `.firebaserc`

`firebase_bootstrap.dart` initializes Firebase from the **native** config
(`google-services.json` / `GoogleService-Info.plist`), so no committed Dart
imports the generated options. A fresh clone still compiles and runs (demo mode)
without any of these files; add them (via `flutterfire configure`) to enable
real Firebase.

## Deploy pipelines

Two GitHub Actions workflows (`.github/workflows/`), both **manual-trigger only**
(`workflow_dispatch`) — they do **not** run on push/PR. Run them from the
repo's **Actions** tab.

- **android.yml** → builds a signed **App Bundle** and uploads to **Google Play**
  (track selectable: internal / alpha / beta / production).
- **ios.yml** → builds a signed **IPA** and uploads to **TestFlight**.

### Required repo secrets
Add under **Settings → Secrets and variables → Actions**.

**Shared (Firebase config):**
| Secret | How to produce |
| --- | --- |
| `GOOGLE_SERVICES_JSON` | `base64 -i android/app/google-services.json \| pbcopy` |
| `GOOGLE_SERVICE_INFO_PLIST` | `base64 -i ios/Runner/GoogleService-Info.plist \| pbcopy` |

**Android (Play):**
| Secret | What it is |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore (store) password |
| `ANDROID_KEY_ALIAS` | key alias |
| `ANDROID_KEY_PASSWORD` | key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play Console service-account JSON (paste the file contents) |

**iOS (TestFlight):**
| Secret | What it is |
| --- | --- |
| `IOS_DIST_CERT_P12_BASE64` | Apple Distribution cert+key as `.p12`, base64 |
| `IOS_DIST_CERT_PASSWORD` | password set when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile, base64 (its UUID + name are read from the profile automatically) |
| `IOS_TEAM_ID` | Apple Developer Team ID (this project's is `GMAMAXJ88G`) |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | contents of the API key `.p8` file |

### One-time prerequisites (before the first deploy)
- **Play:** the app listing must already exist and have had **one AAB uploaded
  manually** — the API can't create the app or publish the very first release.
  Give the service account "Release manager" access in the Play Console.
- **App Store:** the app record must exist in App Store Connect, and the
  provisioning profile must be an **App Store** distribution profile for
  `app.auaha.functionalparenting`.
- Bump `version:` in `pubspec.yaml` for each new build (App Store/Play reject
  duplicate build numbers).

Android release signing is wired in `android/app/build.gradle.kts` via a
gitignored `key.properties` (the workflow writes it from the secrets above; when
absent, local release builds fall back to debug keys).

## Content CMS (Firestore-backed)

Tips, challenges, reflections, and scripts live in Firestore collections
(`tips`, `challenges`, `reflections`, `scripts`) and are edited in-app.

- **Repository:** `core/services/content_repository.dart` (streams + CRUD + seed).
- **Providers:** `core/providers/content_provider.dart` — stream providers for the
  admin lists, plus resolved `tipsProvider`/etc. that show **active** items and
  fall back to the bundled seed content when Firestore is empty/offline/demo, so
  the app is never blank.
- **Admin UI:** `features/admin/presentation/admin_screen.dart` — tabbed editor
  (add / edit / delete / show-hide / reorder via `order`) reachable from
  **Profile → Founder tools → Content CMS**. Includes a one-tap **Seed starter
  content** action that pushes the bundled library into any empty collection.
- **Access:** gated by `core/providers/admin_provider.dart` (email allowlist;
  demo mode counts as admin for local testing). Enforced server-side by
  `firestore.rules` — **public read, admin-only write**.

Keep the allowlist in `admin_provider.dart` and `firestore.rules` in sync, and
**add the founder's email to both**. Deploy rules with:

```bash
firebase deploy --only firestore:rules
```

## Roadmap (post-scaffold)
- Firebase Auth wired to real accounts (done; admin allowlist for the founder)
- Push notifications for daily tip / challenge
- Streaks & progress persistence (`shared_preferences` dep already added)
- Paid tiers: Starter Toolkit + self-paced course (in-app purchases / RevenueCat)
- Real booking link (Calendly) on Workshops
- Course module player (video + audio + reflection + planning)
