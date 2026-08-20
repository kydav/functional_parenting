import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thin wrapper around RevenueCat (`purchases_flutter`) for the one-time
/// Starter Toolkit unlock.
///
/// RevenueCat is the source of truth for entitlements — CustomerInfo is synced
/// across devices via the RevenueCat app-user-id, which we tie to the Firebase
/// uid so a purchase follows the account. Until the public SDK keys below are
/// filled in, [isConfigured] is false and every method is a safe no-op, so the
/// app still runs and the paywall falls back to its "coming soon" copy.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  // ── Fill these from RevenueCat → Project settings → API keys ──────────────
  // These are the *public* SDK keys (safe to ship in the app binary).
  static const String _appleApiKey = 'appl_ogTiOrUneBTCyhgIplVpFXAbxME';
  static const String _googleApiKey = 'goog_NqsuffbAsEingnRQyJsxXrSAWPM';

  /// The entitlement identifier configured in RevenueCat (Project → Entitlements).
  static const String entitlementId = 'Functional Parenting Pro';

  bool get isConfigured {
    if (Platform.isIOS || Platform.isMacOS) return _appleApiKey.isNotEmpty;
    if (Platform.isAndroid) return _googleApiKey.isNotEmpty;
    return false;
  }

  String get _apiKey => (Platform.isAndroid) ? _googleApiKey : _appleApiKey;

  /// Configures RevenueCat and keeps the app-user-id in sync with Firebase Auth.
  /// Safe to call unconditionally; does nothing when keys aren't set.
  Future<void> configure() async {
    if (!isConfigured) return;
    try {
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = FirebaseAuth.instance.currentUser?.uid,
      );
      // Follow the signed-in account for the rest of the process.
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        try {
          if (user != null) {
            await Purchases.logIn(user.uid);
            final email = user.email;
            if (email != null && email.isNotEmpty) {
              await Purchases.setEmail(email);
            }
            final name = user.displayName;
            if (name != null && name.isNotEmpty) {
              await Purchases.setDisplayName(name);
            }
          } else {
            await Purchases.logOut();
          }
        } catch (e) {
          debugPrint('RevenueCat identity sync failed: $e');
        }
      });
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }

  bool entitlementActive(CustomerInfo info) =>
      info.entitlements.active.containsKey(entitlementId);

  /// The package a parent buys to unlock the toolkit — the first package in the
  /// current offering. Returns null when unconfigured or no offering is set up.
  /// Used by the legacy (one-time) paywall fallback.
  Future<Package?> proPackage() async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const [];
    return packages.isEmpty ? null : packages.first;
  }

  /// The tiered packages shown on the paywall, in display order: monthly, annual,
  /// lifetime. Any slot not configured in the current offering is omitted. All of
  /// them grant the same [entitlementId], so the entitlement check is unchanged.
  Future<List<Package>> proPackages() async {
    if (!isConfigured) return const [];
    final current = (await Purchases.getOfferings()).current;
    if (current == null) return const [];
    return [
      if (current.monthly != null) current.monthly!,
      if (current.annual != null) current.annual!,
      if (current.lifetime != null) current.lifetime!,
    ];
  }
}
