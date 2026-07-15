import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content.dart';

/// ── Seed content ────────────────────────────────────────────────────────────
/// Placeholder library so the free tier is fully navigable before the CMS
/// (Firestore) is wired up. Copy is illustrative and should be replaced with
/// the founder's real material.

const _tips = <ParentingTip>[
  ParentingTip(
    id: 't1',
    text:
        'Behavior is communication. Before you correct it, ask what it is trying to tell you.',
  ),
  ParentingTip(
    id: 't2',
    text:
        'Connect before you direct — a regulated child hears you; a flooded one cannot.',
  ),
  ParentingTip(
    id: 't3',
    text:
        'Name the feeling out loud. "You are really frustrated" lowers the temperature faster than "calm down."',
  ),
  ParentingTip(
    id: 't4',
    text:
        'Give the transition a countdown. Surprise endings feel like losses to a child.',
  ),
  ParentingTip(
    id: 't5',
    text:
        'Praise the effort, not the outcome. Effort is the thing they can repeat tomorrow.',
  ),
  ParentingTip(
    id: 't6',
    text:
        'A consequence teaches best when it is small, immediate, and predictable — not big and delayed.',
  ),
  ParentingTip(
    id: 't7',
    text:
        'Your calm is the intervention. Regulate yourself first, then the room follows.',
  ),
];

const _challenges = <ParentingChallenge>[
  ParentingChallenge(
    id: 'c1',
    title: 'One-on-one ten',
    description:
        'Spend ten uninterrupted, phone-free minutes today letting your child lead the play.',
  ),
  ParentingChallenge(
    id: 'c2',
    title: 'Catch them being good',
    description:
        'Notice and name three positive behaviors out loud before dinner.',
  ),
  ParentingChallenge(
    id: 'c3',
    title: 'The pause',
    description:
        'Next time you feel the urge to react, take one slow breath before you respond.',
  ),
  ParentingChallenge(
    id: 'c4',
    title: 'Ask, don\'t tell',
    description: 'Replace one command today with a curious question.',
  ),
  ParentingChallenge(
    id: 'c5',
    title: 'Name it to tame it',
    description:
        'Label your child\'s emotion once today before offering any solution.',
  ),
  ParentingChallenge(
    id: 'c6',
    title: 'Repair',
    description:
        'If a moment goes sideways, circle back later and reconnect. Repair is the lesson.',
  ),
  ParentingChallenge(
    id: 'c7',
    title: 'Predictable transition',
    description: 'Give a five-minute warning before every transition today.',
  ),
];

const _reflections = <ReflectionPrompt>[
  ReflectionPrompt(
    id: 'r1',
    prompt: 'When did I feel most connected to my child today?',
  ),
  ReflectionPrompt(
    id: 'r2',
    prompt: 'What triggered me today, and what was underneath it?',
  ),
  ReflectionPrompt(
    id: 'r3',
    prompt: 'What was my child\'s behavior trying to communicate?',
  ),
  ReflectionPrompt(
    id: 'r4',
    prompt: 'Where did I respond instead of react? How did it go?',
  ),
  ReflectionPrompt(
    id: 'r5',
    prompt: 'What is one thing I want to do differently tomorrow?',
  ),
  ReflectionPrompt(
    id: 'r6',
    prompt: 'What did I handle well today that I want to remember?',
  ),
  ReflectionPrompt(
    id: 'r7',
    prompt: 'When did I model the calm I want my child to learn?',
  ),
];

const _scripts = <Script>[
  Script(
    id: 's1',
    situation: 'Refusing to leave somewhere fun',
    category: 'Transitions',
    script:
        '"It\'s almost time to go. Do you want to hop like a frog to the car, or walk like a giant? You choose."',
    why:
        'A choice restores the sense of control the transition took away, so the child does not have to fight to get it back.',
  ),
  Script(
    id: 's2',
    situation: 'Big meltdown in public',
    category: 'Big feelings',
    script:
        '"You\'re having a really big feeling. I\'m right here. I\'ll wait with you until it passes."',
    why:
        'Co-regulation, not correction. Presence tells the nervous system it is safe to come down.',
  ),
  Script(
    id: 's3',
    situation: 'Not listening to a request',
    category: 'Cooperation',
    script:
        '"I\'m going to ask one more time, then I\'ll help your body do it. Shoes on, or I help with shoes?"',
    why:
        'Clear, calm follow-through teaches that words are reliable — which actually reduces future testing.',
  ),
  Script(
    id: 's4',
    situation: 'Sibling conflict',
    category: 'Cooperation',
    script:
        '"You both want the same thing. Let\'s figure out a plan that works for two people."',
    why:
        'Names the shared goal instead of assigning a villain, which keeps the child in problem-solving mode.',
  ),
  Script(
    id: 's5',
    situation: 'Bedtime stalling',
    category: 'Transitions',
    script:
        '"Two books tonight. You pick which two while I turn down the lights."',
    why:
        'A bounded choice makes the limit feel like theirs, reducing the negotiation loop.',
  ),
];

/// Simple deterministic "index for today" so every user sees the same daily
/// item and it rotates once per day.
int _dayIndex(int length) {
  final epochDay = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 86400000;
  return epochDay % length;
}

// ── Providers (the seam for future Firestore-backed content) ─────────────────

final allTipsProvider = Provider<List<ParentingTip>>((_) => _tips);
final allChallengesProvider = Provider<List<ParentingChallenge>>(
  (_) => _challenges,
);
final allReflectionsProvider = Provider<List<ReflectionPrompt>>(
  (_) => _reflections,
);
final scriptsProvider = Provider<List<Script>>((_) => _scripts);

final dailyTipProvider = Provider<ParentingTip>((ref) {
  final tips = ref.watch(allTipsProvider);
  return tips[_dayIndex(tips.length)];
});

final dailyChallengeProvider = Provider<ParentingChallenge>((ref) {
  final items = ref.watch(allChallengesProvider);
  return items[_dayIndex(items.length)];
});

final dailyReflectionProvider = Provider<ReflectionPrompt>((ref) {
  final items = ref.watch(allReflectionsProvider);
  return items[_dayIndex(items.length)];
});
