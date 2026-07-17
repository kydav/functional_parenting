import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the [SharedPreferences] instance. Overridden in `main()` with the real
/// instance loaded at startup.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

String _dayKey([DateTime? date]) {
  final d = date ?? DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

// ─── Daily engagement (reflections, challenge-done, streak) ───────────────────

@immutable
class EngagementState {
  final int streak;
  final bool challengeDoneToday;
  final String reflectionToday;

  const EngagementState({
    required this.streak,
    required this.challengeDoneToday,
    required this.reflectionToday,
  });

  EngagementState copyWith({
    int? streak,
    bool? challengeDoneToday,
    String? reflectionToday,
  }) => EngagementState(
    streak: streak ?? this.streak,
    challengeDoneToday: challengeDoneToday ?? this.challengeDoneToday,
    reflectionToday: reflectionToday ?? this.reflectionToday,
  );
}

class EngagementController extends StateNotifier<EngagementState> {
  EngagementController(this._prefs)
    : super(
        const EngagementState(
          streak: 0,
          challengeDoneToday: false,
          reflectionToday: '',
        ),
      ) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kStreak = 'streak';
  static const _kLastActive = 'lastActiveDay';

  void _load() {
    final today = _dayKey();
    state = EngagementState(
      streak: _liveStreak(),
      challengeDoneToday: _prefs.getBool('challenge_done_$today') ?? false,
      reflectionToday: _prefs.getString('reflection_$today') ?? '',
    );
  }

  /// The stored streak, or 0 if the last active day is older than yesterday
  /// (the streak has lapsed).
  int _liveStreak() {
    final last = _prefs.getString(_kLastActive);
    if (last == null) return 0;
    final stored = _prefs.getInt(_kStreak) ?? 0;
    if (last == _dayKey() ||
        last == _dayKey(DateTime.now().subtract(const Duration(days: 1)))) {
      return stored;
    }
    return 0;
  }

  Future<void> setChallengeDone({required bool done}) async {
    final today = _dayKey();
    await _prefs.setBool('challenge_done_$today', done);
    if (done) await _recordEngagement();
    state = state.copyWith(challengeDoneToday: done, streak: _liveStreak());
  }

  Future<void> saveReflection(String prompt, String text) async {
    final existing = (_prefs.getString('reflections')) ?? '[]';
    final reflections = (jsonDecode(existing) as List)
        .map((e) => Reflection.fromJson(e as Map<String, dynamic>))
        .toList();
    final today = _dayKey();
    reflections.add(Reflection(dateKey: today, prompt: prompt, text: text));
    await _prefs.setString(
      'reflections',
      jsonEncode(reflections.map((e) => e.toJson()).toList()),
    );

    if (text.trim().isNotEmpty) await _recordEngagement();
    state = state.copyWith(reflectionToday: text, streak: _liveStreak());
  }

  Future<List<Reflection>> getPastReflections() async {
    final existing = (_prefs.getString('reflections')) ?? '[]';
    final reflections = (jsonDecode(existing) as List)
        .map((e) => Reflection.fromJson(e as Map<String, dynamic>))
        .toList();
    return reflections;
  }

  /// Advances the streak once per calendar day of engagement.
  Future<void> _recordEngagement() async {
    final today = _dayKey();
    final last = _prefs.getString(_kLastActive);
    if (last == today) return; // already counted today
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final current = _prefs.getInt(_kStreak) ?? 0;
    final next = last == yesterday ? current + 1 : 1;
    await _prefs.setInt(_kStreak, next);
    await _prefs.setString(_kLastActive, today);
  }
}

final engagementProvider =
    StateNotifierProvider<EngagementController, EngagementState>(
      (ref) => EngagementController(ref.watch(sharedPreferencesProvider)),
    );

// ─── Notification settings ────────────────────────────────────────────────────

@immutable
class NotificationSettings {
  final bool tipEnabled;
  final bool challengeEnabled;

  const NotificationSettings({
    required this.tipEnabled,
    required this.challengeEnabled,
  });

  NotificationSettings copyWith({bool? tipEnabled, bool? challengeEnabled}) =>
      NotificationSettings(
        tipEnabled: tipEnabled ?? this.tipEnabled,
        challengeEnabled: challengeEnabled ?? this.challengeEnabled,
      );
}

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController(this._prefs)
    : super(
        NotificationSettings(
          tipEnabled: _prefs.getBool(_kTip) ?? true,
          challengeEnabled: _prefs.getBool(_kChallenge) ?? true,
        ),
      );

  final SharedPreferences _prefs;
  final _notifs = NotificationService.instance;

  static const _kTip = 'notif_tip';
  static const _kChallenge = 'notif_challenge';

  /// Re-applies the saved preferences on startup so scheduled notifications
  /// survive reinstalls/updates.
  Future<void> applyOnLaunch() async {
    if (state.tipEnabled) await _notifs.scheduleDailyTip();
    if (state.challengeEnabled) await _notifs.scheduleDailyChallenge();
  }

  Future<void> setTipEnabled({required bool value}) async {
    await _prefs.setBool(_kTip, value);
    state = state.copyWith(tipEnabled: value);
    if (value) {
      if (await _notifs.requestPermission()) {
        await _notifs.scheduleDailyTip();
      }
    } else {
      await _notifs.cancelTip();
    }
  }

  Future<void> setChallengeEnabled({required bool value}) async {
    await _prefs.setBool(_kChallenge, value);
    state = state.copyWith(challengeEnabled: value);
    if (value) {
      if (await _notifs.requestPermission()) {
        await _notifs.scheduleDailyChallenge();
      }
    } else {
      await _notifs.cancelChallenge();
    }
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
      (ref) =>
          NotificationSettingsController(ref.watch(sharedPreferencesProvider)),
    );

class Reflection {
  final String dateKey;
  final String prompt;
  final String text;

  const Reflection({
    required this.dateKey,
    required this.prompt,
    required this.text,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
    dateKey: json['dateKey'] as String,
    prompt: json['prompt'] as String,
    text: json['text'] as String,
  );

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'prompt': prompt,
    'text': text,
  };
}
