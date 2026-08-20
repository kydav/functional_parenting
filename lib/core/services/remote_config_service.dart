import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Remote Config for runtime feature flags.
///
/// Right now it hosts a single kill-switch, [useTieredPaywall]: the tiered
/// (monthly / annual / lifetime) paywall is the default, but if live billing
/// misbehaves we can flip this to false in the Firebase console and the app
/// reverts to the legacy one-time paywall instantly — no app-store review.
///
/// Fetch is best-effort and non-blocking: if it fails (offline, misconfigured),
/// the compiled-in defaults apply, so the flag always has a safe value.
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  static const String _kUseTieredPaywall = 'use_tiered_paywall';

  FirebaseRemoteConfig? _rc;

  /// Sets defaults and does a best-effort fetch. Safe to call unconditionally;
  /// must never block or fail app startup.
  Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await rc.setDefaults(const {_kUseTieredPaywall: true});
      _rc = rc;
      await rc.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config init skipped: $e');
    }
  }

  /// Whether to show the new tiered paywall. Defaults to true (safe if unfetched).
  bool get useTieredPaywall => _rc?.getBool(_kUseTieredPaywall) ?? true;
}
