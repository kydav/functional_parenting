// Content models for the app. The four CMS-managed types
// (ParentingTip, ParentingChallenge, ReflectionPrompt, Script) support
// Firestore serialization + editing; DecisionNode and AssessmentQuestion stay
// static in code for now.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared fields for every CMS-managed content item.
mixin CmsItem {
  String get id;

  /// Sort order within its collection (ascending).
  int get order;

  /// Soft on/off switch so the founder can hide an item without deleting it.
  bool get active;

  /// When true, the item is only presented to Pro users. Free by default.
  bool get pro;
}

class ParentingTip with CmsItem {
  @override
  final String id;
  final String text;
  final String? source;
  @override
  final int order;
  @override
  final bool active;
  @override
  final bool pro;

  const ParentingTip({
    required this.id,
    required this.text,
    this.source,
    this.order = 0,
    this.active = true,
    this.pro = false,
  });

  factory ParentingTip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ParentingTip(
      id: doc.id,
      text: (d['text'] ?? '') as String,
      source: d['source'] as String?,
      order: (d['order'] ?? 0) as int,
      active: (d['active'] ?? true) as bool,
      pro: (d['pro'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'source': source,
    'order': order,
    'active': active,
    'pro': pro,
  };

  ParentingTip copyWith({
    String? text,
    String? source,
    int? order,
    bool? active,
    bool? pro,
  }) => ParentingTip(
    id: id,
    text: text ?? this.text,
    source: source ?? this.source,
    order: order ?? this.order,
    active: active ?? this.active,
    pro: pro ?? this.pro,
  );
}

class ParentingChallenge with CmsItem {
  @override
  final String id;
  final String title;
  final String description;
  @override
  final int order;
  @override
  final bool active;
  @override
  final bool pro;

  const ParentingChallenge({
    required this.id,
    required this.title,
    required this.description,
    this.order = 0,
    this.active = true,
    this.pro = false,
  });

  factory ParentingChallenge.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return ParentingChallenge(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      order: (d['order'] ?? 0) as int,
      active: (d['active'] ?? true) as bool,
      pro: (d['pro'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'order': order,
    'active': active,
    'pro': pro,
  };

  ParentingChallenge copyWith({
    String? title,
    String? description,
    int? order,
    bool? active,
    bool? pro,
  }) => ParentingChallenge(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    order: order ?? this.order,
    active: active ?? this.active,
    pro: pro ?? this.pro,
  );
}

class ReflectionPrompt with CmsItem {
  @override
  final String id;
  final String prompt;
  @override
  final int order;
  @override
  final bool active;
  @override
  final bool pro;

  const ReflectionPrompt({
    required this.id,
    required this.prompt,
    this.order = 0,
    this.active = true,
    this.pro = false,
  });

  factory ReflectionPrompt.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ReflectionPrompt(
      id: doc.id,
      prompt: (d['prompt'] ?? '') as String,
      order: (d['order'] ?? 0) as int,
      active: (d['active'] ?? true) as bool,
      pro: (d['pro'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'prompt': prompt,
    'order': order,
    'active': active,
    'pro': pro,
  };

  ReflectionPrompt copyWith({
    String? prompt,
    int? order,
    bool? active,
    bool? pro,
  }) => ReflectionPrompt(
    id: id,
    prompt: prompt ?? this.prompt,
    order: order ?? this.order,
    active: active ?? this.active,
    pro: pro ?? this.pro,
  );
}

/// A ready-to-use phrase parents can say in a charged moment.
class Script with CmsItem {
  @override
  final String id;
  final String situation; // e.g. "Refusing to leave the park"
  final String category; // e.g. "Transitions", "Big feelings"
  final String script; // the words to say
  final String? why; // the functional reasoning behind it
  @override
  final int order;
  @override
  final bool active;
  @override
  final bool pro;

  const Script({
    required this.id,
    required this.situation,
    required this.category,
    required this.script,
    this.why,
    this.order = 0,
    this.active = true,
    this.pro = false,
  });

  factory Script.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Script(
      id: doc.id,
      situation: (d['situation'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      script: (d['script'] ?? '') as String,
      why: d['why'] as String?,
      order: (d['order'] ?? 0) as int,
      active: (d['active'] ?? true) as bool,
      pro: (d['pro'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'situation': situation,
    'category': category,
    'script': script,
    'why': why,
    'order': order,
    'active': active,
    'pro': pro,
  };

  Script copyWith({
    String? situation,
    String? category,
    String? script,
    String? why,
    int? order,
    bool? active,
    bool? pro,
  }) => Script(
    id: id,
    situation: situation ?? this.situation,
    category: category ?? this.category,
    script: script ?? this.script,
    why: why ?? this.why,
    order: order ?? this.order,
    active: active ?? this.active,
    pro: pro ?? this.pro,
  );
}

/// One node in the "What should I do?" decision tool.
class DecisionNode {
  final String id;
  final String question;
  final List<DecisionOption> options;
  final String? guidance; // terminal advice when options is empty

  const DecisionNode({
    required this.id,
    required this.question,
    this.options = const [],
    this.guidance,
  });

  bool get isLeaf => options.isEmpty;
}

class DecisionOption {
  final String label;
  final String nextId;

  const DecisionOption({required this.label, required this.nextId});
}

/// One question in the single free behavior-pattern assessment.
class AssessmentQuestion {
  final String id;
  final String text;
  final String function; // which behavior function this maps to

  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.function,
  });
}
