import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/router/router.dart';
import 'package:functional_parenting/core/services/notification_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  await NotificationService.instance.init();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  // Re-apply saved notification schedules on every launch.
  await container.read(notificationSettingsProvider.notifier).applyOnLaunch();

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
    return MaterialApp.router(
      title: 'Functional Parenting',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
