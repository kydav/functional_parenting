import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_bootstrap.dart';
import 'auth_provider.dart';

/// Emails allowed to edit content in the in-app CMS. Keep in sync with the
/// `isAdmin()` allowlist in `firestore.rules` (rules are the real enforcement;
/// this just controls what UI is shown).
///
/// TODO: add the founder's email here (and in firestore.rules).
const kAdminEmails = <String>{'ky.s.dav@gmail.com'};

/// Whether the current user may access the admin CMS. In demo mode (no Firebase)
/// this is true so the CMS can be exercised locally without a real account.
final isAdminProvider = Provider<bool>((ref) {
  if (!firebaseReady) return true;
  final auth = ref.watch(authNotifierProvider);
  final email = auth.userEmail.toLowerCase();
  return email.isNotEmpty && kAdminEmails.contains(email);
});
