import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:functional_parenting/core/models/content.dart';
import 'package:functional_parenting/core/providers/content_seed.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/services/content_repository.dart';

/// ── Seed content ────────────────────────────────────────────────────────────
/// Two tiers, both bundled (used as the fallback so the app is never blank, and
/// as the payload for the admin "Seed to Firestore" action):
///  • Free rotation — 7 of each, undated. Free users cycle these day to day.
///  • Pro year library — 365 of each, tagged with a calendar month/day so Pro
///    users get the specific item for today's date.
/// Raw strings live in content_seed.dart; ids and `order` are by position, and
/// Pro items get their month/day from day-of-year (item 1 → Jan 1 … 365 → Dec 31).

// Fixed non-leap calendar; maps day-of-year (1..365) → (month, day).
const _monthLengths = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
(int, int) _monthDay(int dayOfYear) {
  var d = dayOfYear;
  for (var m = 0; m < 12; m++) {
    if (d <= _monthLengths[m]) return (m + 1, d);
    d -= _monthLengths[m];
  }
  return (12, 31);
}

// ── Free rotation (7 each, undated, free) ──
final kFreeTips = <ParentingTip>[
  for (var i = 0; i < kFreeTipTexts.length; i++)
    ParentingTip(id: 'ft${i + 1}', order: i, text: kFreeTipTexts[i]),
];
final kFreeChallenges = <ParentingChallenge>[
  for (var i = 0; i < kFreeChallengeSeeds.length; i++)
    ParentingChallenge(
      id: 'fc${i + 1}',
      order: i,
      title: kFreeChallengeSeeds[i].$1,
      description: kFreeChallengeSeeds[i].$2,
    ),
];
final kFreeReflections = <ReflectionPrompt>[
  for (var i = 0; i < kFreeReflectionPrompts.length; i++)
    ReflectionPrompt(
      id: 'fr${i + 1}',
      order: i,
      prompt: kFreeReflectionPrompts[i],
    ),
];

// ── Pro year library (365 each, date-tagged, pro) ──
ParentingTip _proTip(int i) {
  final (m, d) = _monthDay(i + 1);
  return ParentingTip(
    id: 't${i + 1}',
    order: i,
    text: kTipTexts[i],
    pro: true,
    month: m,
    day: d,
  );
}

ParentingChallenge _proChallenge(int i) {
  final (m, d) = _monthDay(i + 1);
  return ParentingChallenge(
    id: 'c${i + 1}',
    order: i,
    title: kChallengeSeeds[i].$1,
    description: kChallengeSeeds[i].$2,
    pro: true,
    month: m,
    day: d,
  );
}

ReflectionPrompt _proReflection(int i) {
  final (m, d) = _monthDay(i + 1);
  return ReflectionPrompt(
    id: 'r${i + 1}',
    order: i,
    prompt: kReflectionPrompts[i],
    pro: true,
    month: m,
    day: d,
  );
}

final kProTips = <ParentingTip>[
  for (var i = 0; i < kTipTexts.length; i++) _proTip(i),
];
final kProChallenges = <ParentingChallenge>[
  for (var i = 0; i < kChallengeSeeds.length; i++) _proChallenge(i),
];
final kProReflections = <ReflectionPrompt>[
  for (var i = 0; i < kReflectionPrompts.length; i++) _proReflection(i),
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

// Free rotation collections.
final tipsStreamProvider = StreamProvider<List<ParentingTip>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchTips() ?? Stream.value(kFreeTips);
});

final challengesStreamProvider = StreamProvider<List<ParentingChallenge>>((
  ref,
) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchChallenges() ?? Stream.value(kFreeChallenges);
});

final reflectionsStreamProvider = StreamProvider<List<ReflectionPrompt>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchReflections() ?? Stream.value(kFreeReflections);
});

final scriptsStreamProvider = StreamProvider<List<Script>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo?.watchScripts() ?? Stream.value(kSeedScripts);
});

/// ── App-facing content (fully static) ───────────────────────────────────────
/// The bundled library is the source of truth. The app reads no Firestore for
/// content, so there are zero per-user content-read costs. The CMS + Seed button
/// still write Firestore, but nothing in the app reads it back until the
/// Firestore path is re-enabled.

final scriptsProvider = Provider<List<Script>>((ref) {
  final isPro = ref.watch(proProvider);
  return kSeedScripts.where((s) => s.active && (isPro || !s.pro)).toList();
});

/// ── Daily selection ──────────────────────────────────────────────────────────
/// Free users cycle the small rotation by day. Pro users get the item tagged
/// for today's calendar date (with a graceful fallback, e.g. on Feb 29).

int _dayIndex(int length) {
  if (length == 0) return 0;
  final epochDay = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 86400000;
  return epochDay % length;
}

int _dayOfYear(DateTime d) => d.difference(DateTime(d.year)).inDays + 1;

T _pickForToday<T extends CmsItem>(List<T> items) {
  final now = DateTime.now();
  for (final it in items) {
    if (it.month == now.month && it.day == now.day) return it;
  }
  // No exact match (incomplete set, or Feb 29) — cycle the dated items.
  final dated = items.where((e) => e.month != null).toList();
  final pool = dated.isEmpty ? items : dated;
  return pool[(_dayOfYear(now) - 1) % pool.length];
}

final dailyTipProvider = Provider<ParentingTip>((ref) {
  if (ref.watch(proProvider)) return _pickForToday(kProTips);
  return kFreeTips[_dayIndex(kFreeTips.length)];
});

final dailyChallengeProvider = Provider<ParentingChallenge>((ref) {
  if (ref.watch(proProvider)) return _pickForToday(kProChallenges);
  return kFreeChallenges[_dayIndex(kFreeChallenges.length)];
});

final dailyReflectionProvider = Provider<ReflectionPrompt>((ref) {
  if (ref.watch(proProvider)) return _pickForToday(kProReflections);
  return kFreeReflections[_dayIndex(kFreeReflections.length)];
});
