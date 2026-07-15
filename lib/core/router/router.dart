import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reset/presentation/reset_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/tools/presentation/assessment_screen.dart';
import '../../features/tools/presentation/decision_tool_screen.dart';
import '../../features/tools/presentation/scripts_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/workshops/presentation/workshops_screen.dart';
import '../presentation/app_shell.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider);
  return GoRouter(
    initialLocation: '/today',
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authNotifier.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Full-screen "Reset Right Now" experience — outside the shell chrome.
      GoRoute(path: '/reset', builder: (context, state) => const ResetScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/today',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TodayScreen()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LearnScreen()),
          ),
          GoRoute(
            path: '/tools',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ToolsScreen()),
            routes: [
              GoRoute(
                path: 'scripts',
                builder: (context, state) => const ScriptsScreen(),
              ),
              GoRoute(
                path: 'decide',
                builder: (context, state) => const DecisionToolScreen(),
              ),
              GoRoute(
                path: 'assessment',
                builder: (context, state) => const AssessmentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/workshops',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WorkshopsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
