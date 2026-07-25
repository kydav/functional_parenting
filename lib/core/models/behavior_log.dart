import 'package:cloud_firestore/cloud_firestore.dart';

/// One ABC behavior-tracking entry: what happened before (antecedent), the
/// behavior, and what happened after (consequence), plus context that helps
/// surface patterns over time.
///
/// The middle fields are multi-select (stored as string arrays); [setting] and
/// [outcome] are single-select. Parsing tolerates the old free-text format so
/// pre-existing logs keep rendering.
class BehaviorLog {
  final String id;
  final DateTime occurredAt;
  final String setting; // where it happened (single-select)
  final List<String> antecedent; // what happened just before
  final List<String> behavior;
  final List<String> consequence; // what happened right after
  final List<String> trigger; // possible added triggers
  final List<String> response; // how the parent responded
  final String outcome; // how it ended (single-select)

  const BehaviorLog({
    required this.id,
    required this.occurredAt,
    this.behavior = const [],
    this.setting = '',
    this.antecedent = const [],
    this.consequence = const [],
    this.trigger = const [],
    this.response = const [],
    this.outcome = '',
  });

  /// Coerce a stored value (either a legacy free-text String or a List) into a
  /// list of non-empty strings.
  static List<String> _list(Object? v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (v is String && v.trim().isNotEmpty) return [v.trim()];
    return const [];
  }

  factory BehaviorLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final ts = d['occurredAt'];
    return BehaviorLog(
      id: doc.id,
      occurredAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      behavior: _list(d['behavior']),
      setting: (d['setting'] ?? '') as String,
      antecedent: _list(d['antecedent']),
      consequence: _list(d['consequence']),
      trigger: _list(d['trigger']),
      response: _list(d['response']),
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
    List<String>? antecedent,
    List<String>? behavior,
    List<String>? consequence,
    List<String>? trigger,
    List<String>? response,
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
