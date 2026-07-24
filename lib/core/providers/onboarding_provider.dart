import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the first-login intro carousel has been seen on this device. Once
/// true, the router stops redirecting to `/welcome` on launch.
const _kIntroSeenKey = 'intro_seen';

class IntroSeenController extends StateNotifier<bool> {
  IntroSeenController(this._prefs)
    : super(_prefs.getBool(_kIntroSeenKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> markSeen() async {
    state = true;
    await _prefs.setBool(_kIntroSeenKey, true);
  }
}

final introSeenProvider = StateNotifierProvider<IntroSeenController, bool>(
  (ref) => IntroSeenController(ref.watch(sharedPreferencesProvider)),
);
