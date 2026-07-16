import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:functional_parenting/core/models/content.dart';

/// Firestore-backed store for the CMS-managed content. Collections are
/// world-readable (public content); writes are restricted to admins by the
/// security rules in `firestore.rules`.
class ContentRepository {
  ContentRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tips => _db.collection('tips');
  CollectionReference<Map<String, dynamic>> get _challenges =>
      _db.collection('challenges');
  CollectionReference<Map<String, dynamic>> get _reflections =>
      _db.collection('reflections');
  CollectionReference<Map<String, dynamic>> get _scripts =>
      _db.collection('scripts');

  // ── Streams (all items, ordered — the CMS shows inactive ones too) ─────────

  Stream<List<ParentingTip>> watchTips() =>
      _ordered(_tips).map((s) => s.docs.map(ParentingTip.fromDoc).toList());

  Stream<List<ParentingChallenge>> watchChallenges() => _ordered(
    _challenges,
  ).map((s) => s.docs.map(ParentingChallenge.fromDoc).toList());

  Stream<List<ReflectionPrompt>> watchReflections() => _ordered(
    _reflections,
  ).map((s) => s.docs.map(ReflectionPrompt.fromDoc).toList());

  Stream<List<Script>> watchScripts() =>
      _ordered(_scripts).map((s) => s.docs.map(Script.fromDoc).toList());

  Stream<QuerySnapshot<Map<String, dynamic>>> _ordered(
    CollectionReference<Map<String, dynamic>> ref,
  ) => ref.orderBy('order').snapshots();

  // ── Writes ─────────────────────────────────────────────────────────────────

  Future<void> saveTip(ParentingTip t) => _save(_tips, t.id, t.toMap());
  Future<void> saveChallenge(ParentingChallenge c) =>
      _save(_challenges, c.id, c.toMap());
  Future<void> saveReflection(ReflectionPrompt r) =>
      _save(_reflections, r.id, r.toMap());
  Future<void> saveScript(Script s) => _save(_scripts, s.id, s.toMap());

  Future<void> deleteTip(String id) => _tips.doc(id).delete();
  Future<void> deleteChallenge(String id) => _challenges.doc(id).delete();
  Future<void> deleteReflection(String id) => _reflections.doc(id).delete();
  Future<void> deleteScript(String id) => _scripts.doc(id).delete();

  /// Upsert by id (empty id → new auto-id doc).
  Future<void> _save(
    CollectionReference<Map<String, dynamic>> ref,
    String id,
    Map<String, dynamic> data,
  ) {
    final payload = {...data, 'updatedAt': FieldValue.serverTimestamp()};
    final doc = id.isEmpty ? ref.doc() : ref.doc(id);
    return doc.set(payload, SetOptions(merge: true));
  }
}
