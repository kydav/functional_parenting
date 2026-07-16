import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:functional_parenting/core/models/content.dart';
import 'package:functional_parenting/core/services/content_repository.dart';

/// ── Seed content ────────────────────────────────────────────────────────────
/// Bundled starter library. Used as the fallback when Firestore is unavailable
/// or a collection is empty, and as the payload for the one-tap "seed" action
/// in the admin CMS. Copy is illustrative — replace with the founder's material
/// (either here, or by editing in the app once seeded).

const kSeedTips = <ParentingTip>[
  ParentingTip(
    id: 't1',
    text:
        'Behavior is communication. Before you correct it, ask what it is trying to tell you.',
  ),
  ParentingTip(
    id: 't2',
    order: 1,
    text:
        'Connect before you direct — a regulated child hears you; a flooded one cannot.',
  ),
  ParentingTip(
    id: 't3',
    order: 2,
    text:
        'Name the feeling out loud. "You are really frustrated" lowers the temperature faster than "calm down."',
  ),
  ParentingTip(
    id: 't4',
    order: 3,
    text:
        'Give the transition a countdown. Surprise endings feel like losses to a child.',
  ),
  ParentingTip(
    id: 't5',
    order: 4,
    text:
        'Praise the effort, not the outcome. Effort is the thing they can repeat tomorrow.',
  ),
  ParentingTip(
    id: 't6',
    order: 5,
    text:
        'A consequence teaches best when it is small, immediate, and predictable — not big and delayed.',
  ),
  ParentingTip(
    id: 't7',
    order: 6,
    text:
        'Your calm is the intervention. Regulate yourself first, then the room follows.',
  ),
];

const kSeedChallenges = <ParentingChallenge>[
  ParentingChallenge(
    id: 'c1',
    title: 'One-on-one ten',
    description:
        'Spend ten uninterrupted, phone-free minutes today letting your child lead the play.',
  ),
  ParentingChallenge(
    id: 'c2',
    order: 1,
    title: 'Catch them being good',
    description:
        'Notice and name three positive behaviors out loud before dinner.',
  ),
  ParentingChallenge(
    id: 'c3',
    order: 2,
    title: 'The pause',
    description:
        'Next time you feel the urge to react, take one slow breath before you respond.',
  ),
  ParentingChallenge(
    id: 'c4',
    order: 3,
    title: "Ask, don't tell",
    description: 'Replace one command today with a curious question.',
  ),
  ParentingChallenge(
    id: 'c5',
    order: 4,
    title: 'Name it to tame it',
    description:
        "Label your child's emotion once today before offering any solution.",
  ),
  ParentingChallenge(
    id: 'c6',
    order: 5,
    title: 'Repair',
    description:
        'If a moment goes sideways, circle back later and reconnect. Repair is the lesson.',
  ),
  ParentingChallenge(
    id: 'c7',
    order: 6,
    title: 'Predictable transition',
    description: 'Give a five-minute warning before every transition today.',
  ),
];

const kSeedReflections = <ReflectionPrompt>[
  ReflectionPrompt(
    id: 'r1',
    prompt: 'When did I feel most connected to my child today?',
  ),
  ReflectionPrompt(
    id: 'r2',
    order: 1,
    prompt: 'What triggered me today, and what was underneath it?',
  ),
  ReflectionPrompt(
    id: 'r3',
    order: 2,
    prompt: "What was my child's behavior trying to communicate?",
  ),
  ReflectionPrompt(
    id: 'r4',
    order: 3,
    prompt: 'Where did I respond instead of react? How did it go?',
  ),
  ReflectionPrompt(
    id: 'r5',
    order: 4,
    prompt: 'What is one thing I want to do differently tomorrow?',
  ),
  ReflectionPrompt(
    id: 'r6',
    order: 5,
    prompt: 'What did I handle well today that I want to remember?',
  ),
  ReflectionPrompt(
    id: 'r7',
    order: 6,
    prompt: 'When did I model the calm I want my child to learn?',
  ),
];

const kSeedScripts = <Script>[
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
    order: 1,
    situation: 'Big meltdown in public',
    category: 'Big feelings',
    script:
        '"You\'re having a really big feeling. I\'m right here. I\'ll wait with you until it passes."',
    why:
        'Co-regulation, not correction. Presence tells the nervous system it is safe to come down.',
  ),
  Script(
    id: 's3',
    order: 2,
    situation: 'Not listening to a request',
    category: 'Cooperation',
    script:
        '"I\'m going to ask one more time, then I\'ll help your body do it. Shoes on, or I help with shoes?"',
    why:
        'Clear, calm follow-through teaches that words are reliable — which actually reduces future testing.',
  ),
  Script(
    id: 's4',
    order: 3,
    situation: 'Sibling conflict',
    category: 'Cooperation',
    script:
        '"You both want the same thing. Let\'s figure out a plan that works for two people."',
    why:
        'Names the shared goal instead of assigning a villain, which keeps the child in problem-solving mode.',
  ),
  Script(
    id: 's5',
    order: 4,
    situation: 'Bedtime stalling',
    category: 'Transitions',
    script:
        '"Two books tonight. You pick which two while I turn down the lights."',
    why:
        'A bounded choice makes the limit feel like theirs, reducing the negotiation loop.',
  ),
];

/// ── Repository ───────────────────────────────────────────────────────────────

final contentRepositoryProvider = Provider<ContentRepository?>((ref) {
  return ContentRepository(FirebaseFirestore.instance);
});

/// ── Live streams (all items incl. inactive — used by the admin CMS) ──────────

final tipsStreamProvider = StreamProvider<List<ParentingTip>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchTips() ?? Stream.value(kSeedTips);
});

final challengesStreamProvider = StreamProvider<List<ParentingChallenge>>((
  ref,
) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchChallenges() ?? Stream.value(kSeedChallenges);
});

final reflectionsStreamProvider = StreamProvider<List<ReflectionPrompt>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchReflections() ?? Stream.value(kSeedReflections);
});

final scriptsStreamProvider = StreamProvider<List<Script>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchScripts() ?? Stream.value(kSeedScripts);
});

/// ── Resolved, app-facing lists ───────────────────────────────────────────────
/// Active items only, with a synchronous fallback to the seed so the app is
/// never blank (during load, offline, before seeding, or in demo mode).

List<T> _resolve<T extends CmsItem>(AsyncValue<List<T>> async, List<T> seed) {
  final live = async.value;
  if (live == null || live.isEmpty) return seed;
  final active = live.where((e) => e.active).toList();
  return active.isEmpty ? seed : active;
}

final tipsProvider = Provider<List<ParentingTip>>(
  (ref) => _resolve(ref.watch(tipsStreamProvider), kSeedTips),
);
final challengesProvider = Provider<List<ParentingChallenge>>(
  (ref) => _resolve(ref.watch(challengesStreamProvider), kSeedChallenges),
);
final reflectionsProvider = Provider<List<ReflectionPrompt>>(
  (ref) => _resolve(ref.watch(reflectionsStreamProvider), kSeedReflections),
);
final scriptsProvider = Provider<List<Script>>(
  (ref) => _resolve(ref.watch(scriptsStreamProvider), kSeedScripts),
);

/// ── Daily selection (deterministic per day) ──────────────────────────────────

int _dayIndex(int length) {
  if (length == 0) return 0;
  final epochDay = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 86400000;
  return epochDay % length;
}

final dailyTipProvider = Provider<ParentingTip>((ref) {
  final tips = ref.watch(tipsProvider);
  return tips[_dayIndex(tips.length)];
});

final dailyChallengeProvider = Provider<ParentingChallenge>((ref) {
  final items = ref.watch(challengesProvider);
  return items[_dayIndex(items.length)];
});

final dailyReflectionProvider = Provider<ReflectionPrompt>((ref) {
  final items = ref.watch(reflectionsProvider);
  return items[_dayIndex(items.length)];
});
