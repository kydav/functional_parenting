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

## CI

Two GitHub Actions pipelines (`.github/workflows/`):
- **android.yml** — format check, analyze, tests, then builds a debug APK.
- **ios.yml** — analyze, tests, then an unsigned iOS build.

Analyze/format/test always run. The **build** steps only run once the Firebase
config secrets are present (otherwise they skip, keeping CI green). To enable
device builds in CI, add these repo secrets (Settings → Secrets → Actions):

```bash
base64 -i android/app/google-services.json | pbcopy      # -> GOOGLE_SERVICES_JSON
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy   # -> GOOGLE_SERVICE_INFO_PLIST
```

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
