import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/providers/theme_provider.dart';
import 'package:functional_parenting/core/router/router.dart';
import 'package:functional_parenting/core/services/notification_service.dart';
import 'package:functional_parenting/core/services/purchase_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Route uncaught Flutter + platform errors to Crashlytics. Disabled in debug
  // so local crashes stay in the console rather than the dashboard.
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  // Configure in-app purchases (no-op until RevenueCat keys are set). Must not
  // block startup.
  try {
    await PurchaseService.instance.configure();
  } catch (e) {
    debugPrint('Purchase setup skipped at launch: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // Notification setup must never prevent the app from starting. If anything
  // here fails (e.g. an unrecognized device timezone), log it and carry on.
  try {
    await NotificationService.instance.init();
    await container.read(notificationSettingsProvider.notifier).applyOnLaunch();
  } catch (e) {
    debugPrint('Notification setup skipped at launch: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FunctionalParentingApp(),
    ),
  );
}

class FunctionalParentingApp extends ConsumerWidget {
  const FunctionalParentingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp.router(
        title: 'Functional Parenting',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
