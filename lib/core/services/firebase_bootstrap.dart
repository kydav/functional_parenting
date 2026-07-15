import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// True once a real Firebase app is initialized. Until `flutterfire configure`
/// generates `firebase_options.dart`, this stays false and the app runs in a
/// local demo session so the UI is fully browsable.
bool firebaseReady = false;

/// Attempts to initialize Firebase. Swap the body for the standard
/// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
/// once `flutterfire configure` has been run (see README).
Future<void> bootstrapFirebase() async {
  try {
    // When firebase_options.dart exists, initialize with it. For now, a bare
    // initializeApp() succeeds only where native config is already present.
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    firebaseReady = false;
    debugPrint('Firebase not configured yet — running in demo mode. ($e)');
  }
}
