# Functional Parenting — Release Checklist

Target: submit to the App Store + Play this week. Work top-down; **Section 0 are
the blockers** that will actually stop a submission.

---

## 0. Blockers — resolve first

- [ ] **Android release build is green in CI** (Crashlytics Gradle plugin bump —
      in progress). Confirm a signed release AAB builds end-to-end.
- [ ] **Decide the in-app purchase story.** The paywall is wired to RevenueCat
      but it's a no-op until keys are set. Choose one:
  - [ ] Ship *with* purchases → complete Section 3 (RevenueCat + store products).
  - [ ] Ship *without* purchases for v1 → confirm the paywall degrades cleanly
        ("available soon"), and that nothing gates the core free experience in a
        confusing way. Revisit IAP in a fast-follow.
- [ ] **iOS: Crashlytics dSYM upload working** (otherwise crash traces are
      unsymbolicated). Verify after the next Archive; add the upload-symbols run
      script / confirm Firebase run phase.
- [ ] **Real-device smoke test passes** on physical iOS + Android hardware (not
      just simulators/emulators).

---

## 1. Versioning & config

- [ ] Bump `version:` in `pubspec.yaml` (currently `1.0.0+21`) — final marketing
      version + build number.
- [ ] iOS build number and Android `versionCode` are unique and ascending vs.
      what's already on TestFlight / Play.
- [ ] Confirm production Firebase config is in the build:
      `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist`
      point at the prod project.
- [ ] `flutter analyze` clean, `dart format` clean.
- [ ] Remove any debug/test toggles (e.g. admin Pro-preview is founder-only —
      confirm it's gated to admin emails).

---

## 2. Firebase (prod project)

- [ ] Firestore **security rules deployed** to prod (owner-only user data,
      admin-only content writes).
- [ ] **Auth providers enabled**: Email/Password, Google, Apple.
- [ ] **Android SHA-1 + SHA-256** for the *release* signing key added to the
      Firebase Android app (Google sign-in fails on release without it).
- [ ] **Sign in with Apple** fully configured (Service ID, key, return URLs).
- [ ] **Crashlytics** receiving data — force a test crash on a release build and
      confirm it lands in the dashboard.
- [ ] **Analytics** events visible in DebugView (login, tool_open, paywall_*,
      etc.).

---

## 3. In-app purchase (only if shipping with purchases)

- [ ] RevenueCat project created; **API keys** set in the app config.
- [ ] Entitlement + offering configured in RevenueCat.
- [ ] **App Store Connect**: the "Starter Toolkit" non-consumable product created,
      priced, and attached to the build; agreements/tax/banking complete.
- [ ] **Play Console**: matching managed product created + active.
- [ ] **Sandbox test**: purchase succeeds, unlocks the toolkit, and **Restore
      purchases** works on a fresh install.

---

## 4. iOS — App Store Connect

- [ ] Bundle ID, signing, provisioning profiles correct (`app.auaha.functionalparenting`).
- [ ] App Privacy "nutrition labels" filled in — declare what's collected:
      email, name, product interaction/analytics, crash data, purchases.
- [ ] **Sign in with Apple present** (required since Google sign-in is offered —
      guideline 4.8). ✅ already implemented.
- [ ] **Account deletion** reachable in-app (App Store requirement). ✅ in
      Account & password screen — confirm it's obvious.
- [ ] Export compliance / encryption question answered.
- [ ] Age rating questionnaire.
- [ ] Store listing: screenshots (all required sizes), description, keywords,
      promotional text, support URL, marketing URL, **privacy policy URL**
      (https://auaha.app/functionalparenting/privacy).
- [ ] Upload build via Xcode/CI → attach to the version → submit for review.

---

## 5. Android — Play Console

- [ ] **Play App Signing** enrolled; upload key / keystore available to CI
      (`key.properties` + keystore from secrets).
- [ ] `versionCode` incremented.
- [ ] **Data safety** form completed — must match the privacy policy (data
      collected, encrypted in transit, deletion available).
- [ ] Content rating questionnaire.
- [ ] Target API level meets the current Play requirement.
- [ ] Store listing: screenshots, feature graphic, short + full description,
      privacy policy URL.
- [ ] Managed product created (if IAP).
- [ ] Roll out via Internal testing → Closed/Open → Production (or straight to
      production review).

---

## 6. Legal & content

- [ ] Privacy policy live and **covers Firebase, Analytics, Crashlytics, and
      purchases** (not just the app generally).
- [ ] Medical/educational disclaimer present where guidance is given (decision
      tool, pattern check). ✅ added — spot-check wording.
- [ ] Terms of use, if you want them linked.

---

## 7. Functional QA (release build, real devices)

- [ ] Fresh install → onboarding/intro → sign up with **each** method
      (email, Google, Apple); name is captured and shows correctly.
- [ ] Friendly auth error messages (bad password, existing email, offline).
- [ ] Core free flows: "What should I do?", Scripts, Behavior-pattern check.
- [ ] Pro flows (or paywall if locked): worksheets, ABC tracker + functions
      graph, Parenting Plans + worksheet prefill, saved recommendations.
- [ ] Paywall → purchase → unlock → restore (sandbox), if IAP is on.
- [ ] Notifications: daily tip, daily challenge, workshop reminder fire.
- [ ] Book-a-call and expert-feedback links open the calendar.
- [ ] Light + dark mode across screens (watch chart/bar contrast).
- [ ] Offline: app opens, no hard crashes; graceful messaging.
- [ ] Sign out + **account deletion** work.

---

## 8. Post-submit

- [ ] Watch Crashlytics for launch-day crashes.
- [ ] Watch Analytics funnel (installs → sign-up → tool use → paywall).
- [ ] Have a hotfix path ready (you build + ship quickly).
