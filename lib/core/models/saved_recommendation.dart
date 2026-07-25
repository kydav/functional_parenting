import 'package:cloud_firestore/cloud_firestore.dart';

/// A recommendation the parent saved from the "What should I do?" tool. We store
/// only the leaf id (plus a denormalized category/title for the list) so the
/// full guidance always renders from the latest content — and respects the
/// user's current Pro status when re-opened.
class SavedRecommendation {
  final String id; // Firestore doc id
  final String leafId; // DecideLeaf.id
  final String category;
  final String title;
  final DateTime savedAt;

  const SavedRecommendation({
    required this.id,
    required this.leafId,
    required this.category,
    required this.title,
    required this.savedAt,
  });

  factory SavedRecommendation.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    final saved = d['savedAt'];
    return SavedRecommendation(
      id: doc.id,
      leafId: (d['leafId'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      title: (d['title'] ?? '') as String,
      savedAt: saved is Timestamp ? saved.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'leafId': leafId,
    'category': category,
    'title': title,
    'savedAt': Timestamp.fromDate(savedAt),
  };
}
