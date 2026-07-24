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
  static const String _appleApiKey = 'appl_CfCVKUArdjpBCCdDdzmAUcELPna';
  static const String _googleApiKey = 'goog_MNPRmjqTxKcRYRiooLASNfwPszS';

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
  Future<Package?> proPackage() async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const [];
    return packages.isEmpty ? null : packages.first;
  }
}
