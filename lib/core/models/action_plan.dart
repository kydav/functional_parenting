import 'package:cloud_firestore/cloud_firestore.dart';

/// A "Functional Parenting Action Plan" — one challenging behavior walked
/// through all five phases of the framework (pages 32–35 of the toolkit).
class ActionPlan {
  final String id;
  final String title; // the behavior / situation being worked on
  final String resetPlan; // Phase 1 — Reset the Parent
  final String goal; // Phase 2 — Define the Goal (skill to build)
  final String function; // Phase 3 — Identify the Function (selected)
  final String structure; // Phase 4 — Build the Structure
  final String response; // Phase 5 — Respond With Purpose
  final DateTime createdAt;

  const ActionPlan({
    required this.id,
    required this.title,
    required this.createdAt,
    this.resetPlan = '',
    this.goal = '',
    this.function = '',
    this.structure = '',
    this.response = '',
  });

  factory ActionPlan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final created = d['createdAt'];
    return ActionPlan(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      resetPlan: (d['resetPlan'] ?? '') as String,
      goal: (d['goal'] ?? '') as String,
      function: (d['function'] ?? '') as String,
      structure: (d['structure'] ?? '') as String,
      response: (d['response'] ?? '') as String,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'resetPlan': resetPlan,
    'goal': goal,
    'function': function,
    'structure': structure,
    'response': response,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  ActionPlan copyWith({
    String? title,
    String? resetPlan,
    String? goal,
    String? function,
    String? structure,
    String? response,
  }) => ActionPlan(
    id: id,
    title: title ?? this.title,
    resetPlan: resetPlan ?? this.resetPlan,
    goal: goal ?? this.goal,
    function: function ?? this.function,
    structure: structure ?? this.structure,
    response: response ?? this.response,
    createdAt: createdAt,
  );
}
