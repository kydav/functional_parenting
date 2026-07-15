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

### Enabling Firebase (next step)
1. `dart pub global activate flutterfire_cli`
2. `flutterfire configure` -> generates `lib/firebase_options.dart`
3. In `lib/core/services/firebase_bootstrap.dart`, initialize with
   `DefaultFirebaseOptions.currentPlatform`. `firebaseReady` flips true and real
   Firebase Auth takes over from the demo session automatically.

## Roadmap (post-scaffold)
- Firebase Auth + Firestore-backed content (CMS for tips/challenges/scripts)
- Push notifications for daily tip / challenge
- Streaks & progress persistence (`shared_preferences` dep already added)
- Paid tiers: Starter Toolkit + self-paced course (in-app purchases / RevenueCat)
- Real booking link (Calendly) on Workshops
- Course module player (video + audio + reflection + planning)
