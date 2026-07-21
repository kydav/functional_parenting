import 'package:cloud_firestore/cloud_firestore.dart';

/// A one-page "Family Action Plan" for a specific behavior goal.
class ActionPlan {
  final String id;
  final String title; // short name for the plan
  final String goal; // the behavior goal
  final String function; // possible function of the behavior
  final String prevention; // prevention strategy
  final String replacement; // replacement behavior to teach
  final String reinforcement; // reinforcement approach
  final String response; // response strategy when it happens
  final String dataToTrack; // what to track
  final DateTime? reviewDate; // when to review progress
  final DateTime createdAt;

  const ActionPlan({
    required this.id,
    required this.title,
    required this.createdAt,
    this.goal = '',
    this.function = '',
    this.prevention = '',
    this.replacement = '',
    this.reinforcement = '',
    this.response = '',
    this.dataToTrack = '',
    this.reviewDate,
  });

  factory ActionPlan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final created = d['createdAt'];
    final review = d['reviewDate'];
    return ActionPlan(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      goal: (d['goal'] ?? '') as String,
      function: (d['function'] ?? '') as String,
      prevention: (d['prevention'] ?? '') as String,
      replacement: (d['replacement'] ?? '') as String,
      reinforcement: (d['reinforcement'] ?? '') as String,
      response: (d['response'] ?? '') as String,
      dataToTrack: (d['dataToTrack'] ?? '') as String,
      reviewDate: review is Timestamp ? review.toDate() : null,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'goal': goal,
    'function': function,
    'prevention': prevention,
    'replacement': replacement,
    'reinforcement': reinforcement,
    'response': response,
    'dataToTrack': dataToTrack,
    'reviewDate': reviewDate == null ? null : Timestamp.fromDate(reviewDate!),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  ActionPlan copyWith({
    String? title,
    String? goal,
    String? function,
    String? prevention,
    String? replacement,
    String? reinforcement,
    String? response,
    String? dataToTrack,
    DateTime? reviewDate,
    bool clearReviewDate = false,
  }) => ActionPlan(
    id: id,
    title: title ?? this.title,
    goal: goal ?? this.goal,
    function: function ?? this.function,
    prevention: prevention ?? this.prevention,
    replacement: replacement ?? this.replacement,
    reinforcement: reinforcement ?? this.reinforcement,
    response: response ?? this.response,
    dataToTrack: dataToTrack ?? this.dataToTrack,
    reviewDate: clearReviewDate ? null : (reviewDate ?? this.reviewDate),
    createdAt: createdAt,
  );
}
