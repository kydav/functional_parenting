import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/models/saved_recommendation.dart';
import 'package:functional_parenting/core/models/worksheet_response.dart';

/// Private per-user store for the Pro toolkit (ABC behavior logs + action
/// plans). Lives under `users/{uid}/…`, which the security rules already lock
/// to the owner.
class ToolkitRepository {
  ToolkitRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _db.collection('users').doc(_uid).collection('behaviorLogs');
  CollectionReference<Map<String, dynamic>> get _plans =>
      _db.collection('users').doc(_uid).collection('actionPlans');
  CollectionReference<Map<String, dynamic>> get _worksheets =>
      _db.collection('users').doc(_uid).collection('worksheets');
  CollectionReference<Map<String, dynamic>> get _savedRecs =>
      _db.collection('users').doc(_uid).collection('savedRecommendations');

  // ── Behavior logs ────────────────────────────────────────────────────────

  Stream<List<BehaviorLog>> watchLogs() => _logs
      .orderBy('occurredAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(BehaviorLog.fromDoc).toList());

  Future<void> saveLog(BehaviorLog log) {
    if (log.id.isEmpty) return _logs.add(log.toMap());
    return _logs.doc(log.id).set(log.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteLog(String id) => _logs.doc(id).delete();

  // ── Action plans ─────────────────────────────────────────────────────────

  Stream<List<ActionPlan>> watchPlans() => _plans
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ActionPlan.fromDoc).toList());

  Future<String> savePlan(ActionPlan plan) async {
    if (plan.id.isEmpty) {
      final ref = await _plans.add(plan.toMap());
      return ref.id;
    }
    await _plans.doc(plan.id).set(plan.toMap(), SetOptions(merge: true));
    return plan.id;
  }

  Future<void> deletePlan(String id) => _plans.doc(id).delete();

  // ── Worksheets ─────────────────────────────────────────────────────────────
  // One doc per worksheet (keyed by its stable id), holding the latest answers.

  Stream<WorksheetResponse> watchWorksheet(String id) => _worksheets
      .doc(id)
      .snapshots()
      .map(
        (doc) => doc.exists
            ? WorksheetResponse.fromDoc(doc)
            : WorksheetResponse(id: id),
      );

  Future<void> saveWorksheet(String id, Map<String, String> answers) =>
      _worksheets
          .doc(id)
          .set(
            WorksheetResponse(id: id, answers: answers).toMap(),
            SetOptions(merge: true),
          );

  // ── Saved recommendations ("What should I do?") ──────────────────────────
  // One doc per saved leaf, keyed by the leaf id so re-saving is idempotent and
  // "is this saved?" is a cheap doc lookup.

  Stream<List<SavedRecommendation>> watchSavedRecommendations() => _savedRecs
      .orderBy('savedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(SavedRecommendation.fromDoc).toList());

  Future<void> saveRecommendation({
    required String leafId,
    required String category,
    required String title,
  }) => _savedRecs.doc(leafId).set({
    'leafId': leafId,
    'category': category,
    'title': title,
    'savedAt': Timestamp.fromDate(DateTime.now()),
  });

  Future<void> deleteRecommendation(String leafId) =>
      _savedRecs.doc(leafId).delete();
}
