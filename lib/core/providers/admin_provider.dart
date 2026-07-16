import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';

/// Emails allowed to edit content in the in-app CMS. Keep in sync with the
/// `isAdmin()` allowlist in `firestore.rules` (rules are the real enforcement;
/// this just controls what UI is shown).
///
const kAdminEmails = <String>{
  'ky.s.dav@gmail.com',
  'taylorthomascoaching@gmail.com',
};

/// Whether the current user may access the admin CMS. In demo mode (no Firebase)
/// this is true so the CMS can be exercised locally without a real account.
final isAdminProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final email = auth.userEmail.toLowerCase();
  return email.isNotEmpty && kAdminEmails.contains(email);
});
