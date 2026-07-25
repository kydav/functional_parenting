// Content + tree for the "What should I do?" branching tool.
//
// A DecideStep is either a question (has options) or a result (has a leaf).
// Leaves split their content into a free part (note + whatsHappening, the
// "why") and a Pro part (the actionable coaching: do-now, scripts, avoid,
// after-calm). The screen renders the free part for everyone and gates the
// rest behind the toolkit paywall.

class DecideStep {
  final String? question;
  final List<DecideOption> options;
  final DecideLeaf? leaf;
  const DecideStep({this.question, this.options = const [], this.leaf});
  bool get isLeaf => leaf != null;
}

class DecideOption {
  final String label;
  final DecideStep next;
  const DecideOption(this.label, this.next);
}

class DecideLeaf {
  /// Stable id — persisted when a recommendation is saved.
  final String id;

  /// The top-level need this sits under, for context (e.g. shown as a badge).
  final String category;

  /// The specific situation this leaf addresses.
  final String title;

  // ── Free: the "why" ────────────────────────────────────────────────────
  final String? whatsHappening;

  /// A short single-paragraph orientation (used by the "I'm not sure" answers),
  /// shown free in place of the structured sections.
  final String? note;

  // ── Pro: the actionable coaching ───────────────────────────────────────
  final String? doNow;
  final List<String> trySaying;
  final String? avoid;
  final String? afterCalm;

  const DecideLeaf({
    required this.id,
    required this.category,
    required this.title,
    this.whatsHappening,
    this.note,
    this.doNow,
    this.trySaying = const [],
    this.avoid,
    this.afterCalm,
  });

  bool get hasProContent =>
      doNow != null ||
      trySaying.isNotEmpty ||
      avoid != null ||
      afterCalm != null;
}

// ════════════════════════════════════════════════════════════════════════
// Branch 1 — Attention or connection
// ════════════════════════════════════════════════════════════════════════

const _attnHelp = DecideStep(
  leaf: DecideLeaf(
    id: 'attn_help',
    category: 'Attention or connection',
    title: 'They need help, reassurance, or connection',
    whatsHappening:
        'Your child may not yet know how to appropriately ask for help, '
        'reassurance, or your attention.',
    doNow:
        'Give a brief moment of calm, focused attention. Acknowledge what they '
        'need, and then prompt a safe and appropriate way to ask for it.',
    trySaying: [
      '“I’m here. You can say, ‘Help me,’ or ‘Stay with me.’”',
      '“You want my attention. Show me or tell me calmly.”',
    ],
    avoid:
        'Avoid making your child escalate further before receiving any '
        'connection. Also avoid providing a long conversation while unsafe or '
        'disruptive behavior continues.',
    afterCalm:
        'Practice the words, gesture, or signal your child can use next time. '
        'Give attention quickly when they use it.',
  ),
);

const _attnArgue = DecideStep(
  leaf: DecideLeaf(
    id: 'attn_argue',
    category: 'Attention or connection',
    title: 'They are pulling me into arguing, repeating, or negotiating',
    whatsHappening:
        'The back-and-forth interaction may be keeping the behavior going, '
        'even if the attention feels negative.',
    doNow:
        'State your answer or limit once. Keep your voice and expression '
        'neutral. Stop debating and return your attention when your child '
        'begins communicating appropriately.',
    trySaying: [
      '“I hear you. The answer is still ___. I’ll talk with you when your voice and body are calm.”',
      '“I have answered. You can choose ___ or ___.”',
    ],
    avoid:
        'Avoid repeating the same explanation, defending your decision, '
        'threatening new consequences, or matching your child’s emotional '
        'intensity.',
    afterCalm:
        'Give positive attention for recovering, accepting the limit, or using '
        'an appropriate request.',
  ),
);

const _attnUnsure = DecideStep(
  leaf: DecideLeaf(
    id: 'attn_unsure',
    category: 'Attention or connection',
    title: 'I’m not sure',
    note:
        'Use the response for connection first: begin with a brief moment of '
        'calm connection, then state the expectation or limit clearly. Watch '
        'whether the behavior decreases when connection is provided or '
        'increases when the conversation continues.',
  ),
);

const _attention = DecideStep(
  question: 'What seems most likely?',
  options: [
    DecideOption('They need help, reassurance, or connection', _attnHelp),
    DecideOption(
      'They are pulling me into arguing, repeating, or negotiating',
      _attnArgue,
    ),
    DecideOption("I'm not sure", _attnUnsure),
  ],
);

// ════════════════════════════════════════════════════════════════════════
// Branch 2 — Avoid or escape something
// ════════════════════════════════════════════════════════════════════════

const _escHard = DecideStep(
  leaf: DecideLeaf(
    id: 'esc_hard',
    category: 'Avoid or escape',
    title: 'The task may be too difficult or unclear',
    whatsHappening:
        'Your child may be avoiding the task because they do not understand '
        'it, do not have the necessary skill, or feel overwhelmed by its size.',
    doNow:
        'Make the task smaller. Show the first step, offer help, or provide '
        'two acceptable ways to begin.',
    trySaying: [
      '“Let’s do the first part together.”',
      '“Do you want to start with ___ or ___?”',
    ],
    avoid:
        'Avoid repeating the entire direction louder or adding more demands '
        'before checking whether your child understands what to do.',
    afterCalm:
        'Consider whether the task needs to be taught, practiced, shortened, '
        'or broken into smaller steps.',
  ),
);

const _escDislike = DecideStep(
  leaf: DecideLeaf(
    id: 'esc_dislike',
    category: 'Avoid or escape',
    title: 'The task is disliked but probably manageable',
    whatsHappening:
        'Your child may be trying to delay or avoid something they can do but '
        'do not want to do.',
    doNow:
        'Keep the expectation in place, but make the next step clear and '
        'manageable. Offer a limited choice when possible.',
    trySaying: [
      '“This still needs to happen. You can do ___ or ___.”',
      '“First ___, then ___.”',
    ],
    avoid:
        'Avoid removing the expectation completely after the behavior '
        'escalates. This can unintentionally teach your child that escalation '
        'is an effective way to escape.',
    afterCalm:
        'Reinforce starting, cooperating, or completing even a small part of '
        'the task.',
  ),
);

const _escBreak = DecideStep(
  leaf: DecideLeaf(
    id: 'esc_break',
    category: 'Avoid or escape',
    title: 'They may need a brief break',
    whatsHappening:
        'Your child may need a short pause before they can successfully '
        'continue.',
    doNow:
        'Offer a brief, clearly defined break. Tell them when the break ends '
        'and what the first step will be afterward.',
    trySaying: [
      '“Take a two-minute break. Then we’ll do the first step together.”',
    ],
    avoid:
        'Avoid making the break open-ended or allowing the original '
        'expectation to disappear without a plan to return.',
    afterCalm:
        'Teach your child how to appropriately request a break before the '
        'behavior escalates.',
  ),
);

const _escUnsure = DecideStep(
  leaf: DecideLeaf(
    id: 'esc_unsure',
    category: 'Avoid or escape',
    title: 'I’m not sure',
    note:
        'Make the task smaller, offer one limited choice, and keep the '
        'expectation clear. This is a reasonable starting point when you are '
        'unsure whether the task is difficult or simply unwanted.',
  ),
);

const _escape = DecideStep(
  question: 'What seems most likely?',
  options: [
    DecideOption('The task may be too difficult or unclear', _escHard),
    DecideOption('The task is disliked but probably manageable', _escDislike),
    DecideOption('They may need a brief break', _escBreak),
    DecideOption("I'm not sure", _escUnsure),
  ],
);

// ════════════════════════════════════════════════════════════════════════
// Branch 3 — An item or activity
// ════════════════════════════════════════════════════════════════════════

const _itemNo = DecideStep(
  leaf: DecideLeaf(
    id: 'item_unavailable',
    category: 'An item or activity',
    title: 'The item or activity is not available',
    whatsHappening:
        'Your child is having difficulty tolerating “no” or accepting that '
        'something is unavailable.',
    doNow:
        'Acknowledge what they want, hold the limit, and offer one or two '
        'genuinely available alternatives.',
    trySaying: [
      '“You really want ___. It isn’t available. You can choose ___ or ___.”',
    ],
    avoid:
        'Avoid repeatedly explaining why, offering increasingly larger '
        'rewards, or giving the item after escalation if the limit was meant '
        'to remain in place.',
    afterCalm:
        'Practice accepting “no” during easier moments and reinforce recovery, '
        'flexibility, and choosing an alternative.',
  ),
);

const _itemLater = DecideStep(
  leaf: DecideLeaf(
    id: 'item_later',
    category: 'An item or activity',
    title: 'It will be available later',
    whatsHappening: 'Waiting may feel unclear or unpredictable to your child.',
    doNow:
        'Make “later” specific. Use a timer, schedule, or clear event that '
        'tells your child when the item or activity will become available.',
    trySaying: [
      '“You can have it after dinner.”',
      '“When the timer ends, it will be your turn.”',
    ],
    avoid:
        'Avoid vague promises such as “maybe later” if you can provide a '
        'clearer answer.',
    afterCalm:
        'Use the same wording or visual support consistently so waiting '
        'becomes more predictable.',
  ),
);

const _itemAfter = DecideStep(
  leaf: DecideLeaf(
    id: 'item_after',
    category: 'An item or activity',
    title: 'It is available after another expectation',
    whatsHappening:
        'Your child may be trying to access the preferred item or activity '
        'without completing the expected step first.',
    doNow:
        'State the sequence clearly and calmly. Keep the requirement '
        'reasonable and avoid renegotiating it repeatedly.',
    trySaying: [
      '“First shoes, then outside.”',
      '“When the toys are in the bin, the tablet is available.”',
    ],
    avoid:
        'Avoid increasing the reward repeatedly during escalation. Only offer '
        'something you were already comfortable providing.',
    afterCalm:
        'Reinforce following the sequence and begin with small, achievable '
        'expectations.',
  ),
);

const _itemUnsure = DecideStep(
  leaf: DecideLeaf(
    id: 'item_unsure',
    category: 'An item or activity',
    title: 'I’m not sure',
    note:
        'Clearly state whether the item is unavailable, available later, or '
        'available after something else. Uncertainty and changing answers can '
        'unintentionally intensify the behavior.',
  ),
);

const _item = DecideStep(
  question: 'Which situation fits best?',
  options: [
    DecideOption('The item or activity is not available', _itemNo),
    DecideOption('It will be available later', _itemLater),
    DecideOption('It is available after another expectation', _itemAfter),
    DecideOption("I'm not sure", _itemUnsure),
  ],
);

// ════════════════════════════════════════════════════════════════════════
// Branch 4 — Help regulating or calming
// ════════════════════════════════════════════════════════════════════════

const _regRespond = DecideStep(
  leaf: DecideLeaf(
    id: 'reg_respond',
    category: 'Help regulating or calming',
    title: 'They are upset but can still respond',
    whatsHappening:
        'Your child is distressed but still able to use some coping skills '
        'with support.',
    doNow: 'Reduce your language and offer two simple regulation choices.',
    trySaying: [
      '“Do you want to sit beside me or have some space?”',
      '“Do you want a drink of water or three slow breaths?”',
    ],
    avoid:
        'Avoid asking many questions, giving a lecture, or expecting your '
        'child to explain everything while still upset.',
    afterCalm:
        'Practice a small number of calming options when your child is already '
        'regulated.',
  ),
);

const _regOverwhelmed = DecideStep(
  leaf: DecideLeaf(
    id: 'reg_overwhelmed',
    category: 'Help regulating or calming',
    title: 'They seem too overwhelmed to respond',
    whatsHappening:
        'Your child may temporarily be unable to process directions, choices, '
        'or explanations.',
    doNow:
        'Use very few words. Reduce noise, activity, and demands when '
        'possible. Stay nearby or provide space based on what usually helps '
        'your child feel safe.',
    trySaying: [
      '“You’re safe. I’m here. We can talk when your body is calmer.”',
    ],
    avoid:
        'Avoid reasoning, requiring apologies, discussing consequences, or '
        'repeatedly asking your child to calm down.',
    afterCalm:
        'Check for common contributors such as fatigue, hunger, pain, sensory '
        'overload, unexpected changes, or demands that exceeded the child’s '
        'current coping ability.',
  ),
);

const _regUnsure = DecideStep(
  leaf: DecideLeaf(
    id: 'reg_unsure',
    category: 'Help regulating or calming',
    title: 'I’m not sure',
    note:
        'Treat your child as overwhelmed first. Reduce language and '
        'stimulation, wait briefly, and then offer one simple choice. You can '
        'return to the expectation after your child is more available to '
        'respond.',
  ),
);

const _regulate = DecideStep(
  question: 'Can your child respond to a simple choice or direction right now?',
  options: [
    DecideOption('Yes — they are upset but can still respond', _regRespond),
    DecideOption('No — they seem too overwhelmed', _regOverwhelmed),
    DecideOption("I'm not sure", _regUnsure),
  ],
);

// ════════════════════════════════════════════════════════════════════════
// Generic response (used by "I'm not sure" → none of these fit)
// ════════════════════════════════════════════════════════════════════════

const _generic = DecideStep(
  leaf: DecideLeaf(
    id: 'generic',
    category: 'A calm place to start',
    title: 'A calm, general response',
    doNow:
        'Lower your voice and reduce the number of words you are using. State '
        'one clear limit or expectation, offer one safe choice, and avoid '
        'bargaining while the behavior continues.',
    trySaying: ['“You’re safe. I’m here. You can choose ___ or ___.”'],
    avoid:
        'Avoid making several new threats, changing the expectation '
        'repeatedly, or trying multiple strategies at the same time.',
    afterCalm:
        'Record what happened immediately before and after the behavior. '
        'Repeated observations may help the pattern become clearer.',
  ),
);

// ════════════════════════════════════════════════════════════════════════
// Branch 5 — "I'm not sure": route from the antecedent to a branch above.
// ════════════════════════════════════════════════════════════════════════

const _notSure = DecideStep(
  question: 'What happened immediately before the behavior?',
  options: [
    DecideOption('My attention moved elsewhere', _attention),
    DecideOption('I gave a direction, request, or transition', _escape),
    DecideOption('I said “no,” ended an activity, or removed access', _item),
    DecideOption(
      'They seemed tired, hungry, overstimulated, or already upset',
      _regulate,
    ),
    DecideOption('None of these fit', _generic),
  ],
);

// ════════════════════════════════════════════════════════════════════════
// Root
// ════════════════════════════════════════════════════════════════════════

const kDecideRoot = DecideStep(
  question: 'What does your child seem to need or want right now?',
  options: [
    DecideOption('Attention or connection', _attention),
    DecideOption('To avoid or escape something', _escape),
    DecideOption('An item or activity', _item),
    DecideOption('Help regulating or calming', _regulate),
    DecideOption("I'm not sure", _notSure),
  ],
);

/// Every leaf in the tree, keyed by id — used to re-open a saved recommendation.
final Map<String, DecideLeaf> _leafIndex = _buildLeafIndex();

Map<String, DecideLeaf> _buildLeafIndex() {
  final out = <String, DecideLeaf>{};
  void walk(DecideStep step) {
    if (step.leaf != null) out[step.leaf!.id] = step.leaf!;
    for (final o in step.options) {
      walk(o.next);
    }
  }

  walk(kDecideRoot);
  return out;
}

DecideLeaf? decideLeafById(String id) => _leafIndex[id];
