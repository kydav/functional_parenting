import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:functional_parenting/core/models/workshop.dart';

/// Firestore access for workshops and their reservations.
///
/// Layout:
///   workshops/{workshopId}                       — admin-only write, public read
///   workshops/{workshopId}/reservations/{uid}    — each user owns their own
class WorkshopRepository {
  WorkshopRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _workshops =>
      _db.collection('workshops');

  CollectionReference<Map<String, dynamic>> _reservations(String workshopId) =>
      _workshops.doc(workshopId).collection('reservations');

  // ── Workshops ──────────────────────────────────────────────────────────────

  /// Active workshops, soonest first (what users see). `active` is filtered
  /// client-side so we only need the automatic single-field index on startsAt
  /// (combining where + orderBy would require a composite index).
  Stream<List<Workshop>> watchActiveWorkshops() => _workshops
      .orderBy('startsAt')
      .snapshots()
      .map((s) => s.docs.map(Workshop.fromDoc).where((w) => w.active).toList());

  /// Every workshop incl. inactive/past (admin management view).
  Stream<List<Workshop>> watchAllWorkshops() => _workshops
      .orderBy('startsAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Workshop.fromDoc).toList());

  Future<String> saveWorkshop(Workshop w) async {
    if (w.id.isEmpty) {
      final ref = await _workshops.add(w.toMap());
      return ref.id;
    }
    await _workshops.doc(w.id).set(w.toMap(), SetOptions(merge: true));
    return w.id;
  }

  Future<void> deleteWorkshop(String id) async {
    final res = await _reservations(id).get();
    for (final r in res.docs) {
      await r.reference.delete();
    }
    await _workshops.doc(id).delete();
  }

  // ── Reservations ─────────────────────────────────────────────────────────

  /// Whether the given user has reserved this workshop.
  Stream<bool> watchMyReservation(String workshopId, String uid) =>
      _reservations(workshopId).doc(uid).snapshots().map((d) => d.exists);

  /// All reservations for a workshop (admin only — see the rules).
  Stream<List<Reservation>> watchReservations(String workshopId) =>
      _reservations(
        workshopId,
      ).snapshots().map((s) => s.docs.map(Reservation.fromDoc).toList());

  Future<void> reserve(String workshopId, String uid, String name) =>
      _reservations(workshopId).doc(uid).set({
        'name': name,
        'reservedAt': FieldValue.serverTimestamp(),
      });

  Future<void> cancelReservation(String workshopId, String uid) =>
      _reservations(workshopId).doc(uid).delete();
}
