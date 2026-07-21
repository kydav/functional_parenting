import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth state. Backed by Firebase Auth when configured; otherwise it runs a
/// local demo session so the whole app is browsable before
/// `flutterfire configure` has been run.
class AuthNotifier extends ChangeNotifier {
  FirebaseAuth? get _auth => FirebaseAuth.instance;

  AuthNotifier() {
    _auth?.authStateChanges().listen((_) => notifyListeners());
  }

  bool get isLoggedIn => _auth!.currentUser != null;
  User? get currentUser => _auth?.currentUser;

  String get userEmail => (_auth!.currentUser?.email ?? '');

  String get userName {
    final user = _auth!.currentUser;
    if (user?.displayName?.isNotEmpty ?? false) return user!.displayName!;
    final email = user?.email ?? '';
    return email.isNotEmpty ? email.split('@').first : 'there';
  }

  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (userName.isNotEmpty) return userName[0].toUpperCase();
    return 'P';
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final cred = await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name != null && name.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(name.trim());
    }
    notifyListeners();
  }

  /// Native Google account picker → Firebase credential. Returns silently if
  /// the user cancels the picker.
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth!.signInWithCredential(credential);
    notifyListeners();
  }

  /// Native Sign in with Apple via Firebase's provider flow.
  Future<void> signInWithApple() async {
    final provider = AppleAuthProvider();
    await _auth!.signInWithProvider(provider);
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth!.sendPasswordResetEmail(email: email);
  }

  Future<void> updateDisplayName(String name) async {
    await _auth!.currentUser?.updateDisplayName(name.trim());
    await _auth!.currentUser?.reload();
    notifyListeners();
  }

  /// Deletes the signed-in user. May throw a `requires-recent-login`
  /// FirebaseAuthException if the session is old — the caller should ask the
  /// user to sign in again and retry.
  Future<void> deleteAccount() async {
    await _auth!.currentUser?.delete();
    notifyListeners();
  }

  Future<void> signOut() async {
    // Also clear the cached Google session so the picker reappears next time.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth!.signOut();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>(
  (ref) => AuthNotifier(),
);
