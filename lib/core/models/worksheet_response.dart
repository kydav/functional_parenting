import 'package:cloud_firestore/cloud_firestore.dart';

/// A parent's saved answers to one worksheet. Stored as a single doc per
/// worksheet under `users/{uid}/worksheets/{worksheetId}` — the latest answers
/// are kept and editable in place. Answer values are keyed by question key.
class WorksheetResponse {
  final String id; // the worksheet's stable id (e.g. 'parent_trigger_map')
  final Map<String, String> answers;
  final DateTime? updatedAt;

  const WorksheetResponse({
    required this.id,
    this.answers = const {},
    this.updatedAt,
  });

  factory WorksheetResponse.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    final raw = (d['answers'] ?? const <String, dynamic>{}) as Map;
    final updated = d['updatedAt'];
    return WorksheetResponse(
      id: doc.id,
      answers: raw.map((k, v) => MapEntry(k as String, (v ?? '') as String)),
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'answers': answers,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
