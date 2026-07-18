import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/models/workshop.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/services/workshop_repository.dart';

final workshopRepositoryProvider = Provider<WorkshopRepository>(
  (ref) => WorkshopRepository(FirebaseFirestore.instance),
);

/// Active workshops (soonest first) — the public/user list.
final workshopsProvider = StreamProvider<List<Workshop>>(
  (ref) => ref.watch(workshopRepositoryProvider).watchActiveWorkshops(),
);

/// Every workshop (admin management view).
final allWorkshopsProvider = StreamProvider<List<Workshop>>(
  (ref) => ref.watch(workshopRepositoryProvider).watchAllWorkshops(),
);

/// Whether the current user has reserved a given workshop.
final myReservationProvider = StreamProvider.family<bool, String>((ref, id) {
  final uid = ref.watch(authNotifierProvider).currentUser?.uid;
  if (uid == null) return Stream.value(false);
  return ref.watch(workshopRepositoryProvider).watchMyReservation(id, uid);
});

/// All reservations for a workshop (admin only).
final reservationsProvider = StreamProvider.family<List<Reservation>, String>(
  (ref, id) => ref.watch(workshopRepositoryProvider).watchReservations(id),
);
