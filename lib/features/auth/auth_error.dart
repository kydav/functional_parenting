import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// True when the error represents the user backing out of a native sign-in
/// sheet (Google/Apple). These aren't failures — callers should stay quiet.
bool isSignInCancellation(Object e) {
  if (e is FirebaseAuthException) {
    return e.code == 'canceled' ||
        e.code == 'web-context-canceled' ||
        e.code == 'user-cancelled';
  }
  if (e is PlatformException) {
    final code = e.code.toLowerCase();
    return code == 'canceled' ||
        code == 'cancelled' ||
        code == 'sign_in_canceled' ||
        code == 'sign_in_cancelled';
  }
  return false;
}

/// Maps auth failures to a short, human-friendly sentence. Never surfaces raw
/// Firebase/platform codes or stack traces to the user.
String friendlyAuthError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return "That email address doesn't look right.";
      case 'user-disabled':
        return 'This account has been disabled. Contact support if you '
            'think this is a mistake.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try signing in '
            'instead.';
      case 'weak-password':
        return 'Please choose a stronger password — at least 6 characters.';
      case 'network-request-failed':
        return "You appear to be offline. Check your connection and try "
            'again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'account-exists-with-different-credential':
        return "You've already signed up with a different sign-in method for "
            'that email.';
      case 'operation-not-allowed':
        return "That sign-in method isn't available right now.";
    }
  }
  return 'Something went wrong. Please try again.';
}
