import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Writes user feedback to Firestore `feedback/{autoId}`. A Cloud Function +
/// the Firestore "Trigger Email" extension can forward new docs to the feedback
/// email; until that's set up the founder still sees every entry in the
/// Firestore console.
class FeedbackService {
  FeedbackService._();

  /// Saves a feedback entry. [rating] is set when it came from the rating
  /// prompt; [source] distinguishes where it was sent from
  /// (`'profile'` | `'rating_prompt'`).
  static Future<void> submit({
    required String message,
    int? rating,
    String source = 'profile',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    String appVersion = '';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version} (${info.buildNumber})';
    } catch (_) {
      // Non-fatal — version is just metadata.
    }

    await FirebaseFirestore.instance.collection('feedback').add({
      'uid': user?.uid,
      'email': user?.email,
      'name': user?.displayName,
      'message': message.trim(),
      'rating': ?rating,
      'source': source,
      'appVersion': appVersion,
      'platform': defaultTargetPlatform.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
