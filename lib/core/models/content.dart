// Static, in-app content models for the free tier. These are intentionally
// plain value types so they can later be hydrated from Firestore without
// touching the UI (the providers are the seam).

class ParentingTip {
  final String id;
  final String text;
  final String? source;

  const ParentingTip({required this.id, required this.text, this.source});
}

class ParentingChallenge {
  final String id;
  final String title;
  final String description;

  const ParentingChallenge({
    required this.id,
    required this.title,
    required this.description,
  });
}

class ReflectionPrompt {
  final String id;
  final String prompt;

  const ReflectionPrompt({required this.id, required this.prompt});
}

/// A ready-to-use phrase parents can say in a charged moment.
class Script {
  final String id;
  final String situation; // e.g. "Refusing to leave the park"
  final String category; // e.g. "Transitions", "Big feelings"
  final String script; // the words to say
  final String? why; // the functional reasoning behind it

  const Script({
    required this.id,
    required this.situation,
    required this.category,
    required this.script,
    this.why,
  });
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
