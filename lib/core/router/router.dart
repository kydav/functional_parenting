import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/presentation/app_shell.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/features/account/presentation/account_screen.dart';
import 'package:functional_parenting/features/admin/presentation/admin_screen.dart';
import 'package:functional_parenting/features/auth/presentation/login_screen.dart';
import 'package:functional_parenting/features/learn/presentation/learn_screen.dart';
import 'package:functional_parenting/features/profile/presentation/profile_screen.dart';
import 'package:functional_parenting/features/reset/presentation/reset_screen.dart';
import 'package:functional_parenting/features/today/presentation/today_screen.dart';
import 'package:functional_parenting/features/tools/presentation/assessment_screen.dart';
import 'package:functional_parenting/features/tools/presentation/decision_tool_screen.dart';
import 'package:functional_parenting/features/tools/presentation/scripts_screen.dart';
import 'package:functional_parenting/features/tools/presentation/tools_screen.dart';
import 'package:functional_parenting/features/workshops/presentation/workshops_screen.dart';
import 'package:go_router/go_router.dart';

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
      // Admin CMS is gated to admins.
      if (state.matchedLocation == '/admin' && !ref.read(isAdminProvider)) {
        return '/today';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Full-screen "Reset Right Now" experience — outside the shell chrome.
      GoRoute(path: '/reset', builder: (context, state) => const ResetScreen()),
      // Admin content CMS — full screen, gated in redirect above.
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      // Account & password management — full screen.
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
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
