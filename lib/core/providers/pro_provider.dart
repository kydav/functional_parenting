import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';

/// Whether the user owns the one-time Pro (Starter Toolkit) unlock.
///
/// Source of truth is `users/{uid}/entitlements/pro` (field `active`), which the
/// purchase flow will set once the in-app purchase completes. Admins are always
/// treated as Pro so the founder/testers can use the tools before the IAP is
/// wired up.
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
  return ref.watch(proEntitlementStreamProvider).value ?? false;
});
