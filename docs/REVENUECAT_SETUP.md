# Starter Toolkit — In-App Purchase setup (RevenueCat)

The app code is fully wired for a **single one-time purchase** that unlocks the
Starter Toolkit (behavior tracker, action-plan builder, behavior-function
guide). Until the two public SDK keys are filled in, everything degrades
gracefully: the paywall shows, but the Unlock button just says "coming soon" and
no purchase is attempted. Admins/founders always have access, and you can comp
any account manually (see the bottom of this doc).

The entitlement identifier the code expects is **`pro`**. Match it exactly.

---

## 1. App Store Connect (iOS)

1. **Agreements, Tax, and Banking** → sign the *Paid Applications* agreement.
   Nothing sells until this is active.
2. Your app → **Monetization → In-App Purchases** → **+** →
   **Non-Consumable** (one-time, permanent unlock).
   - Reference Name: `Starter Toolkit`
   - Product ID: e.g. `fp_starter_toolkit` (save this — you'll paste it into
     RevenueCat).
   - Price: pick a tier.
   - Add a localized display name + description, and a review screenshot.
3. Leave it in "Ready to Submit" — it gets reviewed with your first build that
   references it.

## 2. Google Play Console (Android)

1. **Monetize → Products → In-app products** → **Create product**.
   - Product ID: use the **same** id where possible, e.g. `fp_starter_toolkit`.
   - Set name, description, price, and **Activate** it.
2. You must upload at least one build (internal testing track is fine) that
   includes the billing library before products go live — the `purchases_flutter`
   plugin brings the billing dependency in automatically.

## 3. RevenueCat dashboard

1. Create a **Project** (or use an existing one) and add two **Apps**:
   one Apple, one Google, pointing at the bundle id `app.auaha.*` /
   package name for this app.
   - Apple app: upload the **App Store Connect API key** (or in-app-purchase
     shared secret) so RevenueCat can validate receipts.
   - Google app: upload the **Play service-account JSON** with the Pub/Sub +
     billing permissions RevenueCat asks for.
2. **Products** → import/add both store products (`fp_starter_toolkit` on each
   platform).
3. **Entitlements** → create one called **`pro`** and attach both products to it.
4. **Offerings** → create an offering (the "current" one) and add a **Package**
   containing the product. The app buys `offerings.current.availablePackages.first`,
   so a single default package is all you need.
5. **API keys** (Project settings → API keys) → copy the **public SDK keys**:
   - Apple key → paste into `_appleApiKey`
   - Google key → paste into `_googleApiKey`
   in `lib/core/services/purchase_service.dart`. These are public/client keys and
   are safe to ship in the binary.

## 4. Flip it on in the app

In `lib/core/services/purchase_service.dart`:

```dart
static const String _appleApiKey = 'appl_XXXXXXXXXXXXXXXX';
static const String _googleApiKey = 'goog_XXXXXXXXXXXXXXXX';
```

That's the only code change. On launch the app calls `PurchaseService.configure()`,
ties the RevenueCat app-user-id to the Firebase uid (so the purchase follows the
account across devices), and the paywall's Unlock/Restore buttons go live and
show the real localized price.

## 5. Testing before release

- **iOS**: create a **Sandbox tester** in App Store Connect → Users and Access,
  sign into it on a real device (Settings → App Store → Sandbox account), then
  buy from a TestFlight/dev build. Sandbox purchases are free.
- **Android**: add your Google account to **License testers** in Play Console and
  test from the internal testing track. Test purchases are free/refunded.
- Verify: after buying, the toolkit tiles lose their PRO badge and open the tools;
  reinstall + **Restore purchase** re-unlocks; a second account still sees the
  paywall.

## 6. Comping access without a purchase (founder / reviewers / refunds)

Two ways, no store purchase required:

- **Admin** accounts are always Pro (existing `isAdminProvider`).
- **Any account**: set Firestore `users/{uid}/entitlements/pro` → `{ active: true }`.
  `proProvider` treats that as unlocked. Handy for App Review, giveaways, or
  making someone whole after a refund.

---

**Note for iOS builds:** `purchases_flutter` (like `sign_in_with_apple`) does not
support Swift Package Manager yet, so the project keeps using CocoaPods. Run
`cd ios && pod install` after `flutter pub get` if the build complains about the
missing pod.
