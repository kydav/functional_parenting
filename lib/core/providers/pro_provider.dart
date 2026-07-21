import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/purchase_provider.dart';

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
  if (ref.watch(isAdminProvider)) return true;
  if (ref.watch(revenueCatProProvider)) return true;
  return ref.watch(proEntitlementStreamProvider).value ?? false;
});
