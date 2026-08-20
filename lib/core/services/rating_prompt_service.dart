import 'package:shared_preferences/shared_preferences.dart';

/// Tracks app opens and decides when to surface the rating prompt. State only —
/// the UI flow lives in `rating_dialog.dart`.
class RatingPromptService {
  RatingPromptService._();
  static final RatingPromptService instance = RatingPromptService._();

  static const _kOpenCount = 'rating_open_count';
  static const _kNextAt = 'rating_next_at';
  static const _kCompleted = 'rating_completed';

  /// Show the prompt on the Nth app open.
  static const int _firstPromptAt = 4;

  /// If dismissed without rating, wait this many more opens before asking again.
  static const int _snoozeOpens = 8;

  SharedPreferences? _prefs;
  bool _shownThisSession = false;

  void attach(SharedPreferences prefs) => _prefs = prefs;

  /// Count one app open. Call once per launch.
  Future<void> registerOpen() async {
    final p = _prefs;
    if (p == null) return;
    await p.setInt(_kOpenCount, (p.getInt(_kOpenCount) ?? 0) + 1);
  }

  /// Whether the prompt should show right now (eligible, not completed, and not
  /// already shown this session).
  bool get shouldPrompt {
    final p = _prefs;
    if (p == null || _shownThisSession) return false;
    if (p.getBool(_kCompleted) ?? false) return false;
    final count = p.getInt(_kOpenCount) ?? 0;
    final nextAt = p.getInt(_kNextAt) ?? _firstPromptAt;
    return count >= nextAt;
  }

  /// Mark that we showed it this session, so it can't double-fire.
  void markShown() => _shownThisSession = true;

  /// User dismissed without rating — snooze until a few more opens.
  Future<void> markDismissed() async {
    final p = _prefs;
    if (p == null) return;
    final count = p.getInt(_kOpenCount) ?? 0;
    await p.setInt(_kNextAt, count + _snoozeOpens);
  }

  /// User rated (or was sent to the store) — never ask again.
  Future<void> markCompleted() async => _prefs?.setBool(_kCompleted, true);
}
