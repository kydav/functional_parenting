import 'package:cloud_firestore/cloud_firestore.dart';

/// A live workshop the founder runs. Managed from the admin CMS; users can
/// reserve a spot (stored in the `reservations` subcollection).
class Workshop {
  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final String joinLink;
  final bool active;

  const Workshop({
    required this.id,
    required this.title,
    required this.startsAt,
    this.description = '',
    this.joinLink = '',
    this.active = true,
  });

  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  factory Workshop.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['startsAt'];
    return Workshop(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      startsAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      joinLink: (d['joinLink'] ?? '') as String,
      active: (d['active'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'startsAt': Timestamp.fromDate(startsAt),
    'joinLink': joinLink,
    'active': active,
  };

  Workshop copyWith({
    String? title,
    String? description,
    DateTime? startsAt,
    String? joinLink,
    bool? active,
  }) => Workshop(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    startsAt: startsAt ?? this.startsAt,
    joinLink: joinLink ?? this.joinLink,
    active: active ?? this.active,
  );
}

/// One person's reservation for a workshop. The doc id is the user's uid, so a
/// user can only ever create/delete their own — no writes to the workshop doc.
class Reservation {
  final String uid;
  final String name;
  final DateTime? reservedAt;

  const Reservation({required this.uid, required this.name, this.reservedAt});

  factory Reservation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['reservedAt'];
    return Reservation(
      uid: doc.id,
      name: (d['name'] ?? '') as String,
      reservedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
