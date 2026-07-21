import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';

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
}
