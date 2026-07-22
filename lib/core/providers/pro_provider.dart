import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/providers/purchase_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Founder-only preview switch. Admins are normally treated as Pro so they can
/// use every tool; flipping this off lets the founder see the *free* (locked)
/// experience exactly as a non-paying parent would. Persisted on-device only —
/// it has no effect for non-admins.
class AdminProPreviewController extends StateNotifier<bool> {
  AdminProPreviewController(this._prefs) : super(_prefs.getBool(_key) ?? true);

  final SharedPreferences _prefs;
  static const _key = 'admin_pro_preview';

  Future<void> set({required bool value}) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
}

final adminProPreviewProvider =
    StateNotifierProvider<AdminProPreviewController, bool>(
      (ref) => AdminProPreviewController(ref.watch(sharedPreferencesProvider)),
    );

/// Whether the user owns the one-time Pro (Starter Toolkit) unlock.
///
/// Pro is granted if ANY of these hold:
///  - RevenueCat reports the `pro` entitlement active (the real purchase path);
///  - `users/{uid}/entitlements/pro.active` is true (manual grants / testers);
///  - the user is an admin (founder always has access).
/// The Firestore doc lets the founder comp access without a store purchase.
final proEntitlementStreamProvider = StreamProvider<bool>((ref) {
  final uid = ref.watch(authNotifierProvider).currentUser?.uid;
  if (uid == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('entitlements')
      .doc('pro')
      .snapshots()
      .map((d) => (d.data()?['active'] ?? false) as bool);
});

final proProvider = Provider<bool>((ref) {
  // For admins, the preview switch is the single source of truth so the founder
  // can flip between the paid and free experience at will.
  if (ref.watch(isAdminProvider)) return ref.watch(adminProPreviewProvider);
  if (ref.watch(revenueCatProProvider)) return true;
  return ref.watch(proEntitlementStreamProvider).value ?? false;
});
