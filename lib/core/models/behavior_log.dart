import 'package:cloud_firestore/cloud_firestore.dart';

/// One ABC behavior-tracking entry: what happened before (antecedent), the
/// behavior, and what happened after (consequence), plus context that helps
/// surface patterns over time.
class BehaviorLog {
  final String id;
  final DateTime occurredAt;
  final String setting; // where it happened
  final String
  antecedent; // what happened just before / the request or transition
  final String behavior;
  final String consequence; // what happened right after
  final String trigger; // possible trigger
  final String response; // how the parent responded
  final String outcome; // how it ended / did it work

  const BehaviorLog({
    required this.id,
    required this.occurredAt,
    required this.behavior,
    this.setting = '',
    this.antecedent = '',
    this.consequence = '',
    this.trigger = '',
    this.response = '',
    this.outcome = '',
  });

  factory BehaviorLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['occurredAt'];
    return BehaviorLog(
      id: doc.id,
      occurredAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      behavior: (d['behavior'] ?? '') as String,
      setting: (d['setting'] ?? '') as String,
      antecedent: (d['antecedent'] ?? '') as String,
      consequence: (d['consequence'] ?? '') as String,
      trigger: (d['trigger'] ?? '') as String,
      response: (d['response'] ?? '') as String,
      outcome: (d['outcome'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'occurredAt': Timestamp.fromDate(occurredAt),
    'behavior': behavior,
    'setting': setting,
    'antecedent': antecedent,
    'consequence': consequence,
    'trigger': trigger,
    'response': response,
    'outcome': outcome,
  };

  BehaviorLog copyWith({
    DateTime? occurredAt,
    String? setting,
    String? antecedent,
    String? behavior,
    String? consequence,
    String? trigger,
    String? response,
    String? outcome,
  }) => BehaviorLog(
    id: id,
    occurredAt: occurredAt ?? this.occurredAt,
    setting: setting ?? this.setting,
    antecedent: antecedent ?? this.antecedent,
    behavior: behavior ?? this.behavior,
    consequence: consequence ?? this.consequence,
    trigger: trigger ?? this.trigger,
    response: response ?? this.response,
    outcome: outcome ?? this.outcome,
  );
}
