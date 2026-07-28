import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/presentation/app_shell.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/onboarding_provider.dart';
import 'package:functional_parenting/features/account/presentation/account_screen.dart';
import 'package:functional_parenting/features/admin/presentation/admin_screen.dart';
import 'package:functional_parenting/features/admin/presentation/workshops_admin_screen.dart';
import 'package:functional_parenting/features/auth/presentation/login_screen.dart';
import 'package:functional_parenting/features/learn/presentation/learn_screen.dart';
import 'package:functional_parenting/features/profile/presentation/profile_screen.dart';
import 'package:functional_parenting/features/reflections_screen/reflections_screen.dart';
import 'package:functional_parenting/features/reset/presentation/reset_screen.dart';
import 'package:functional_parenting/features/today/presentation/today_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/action_plan_form_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/action_plan_view_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/action_plans_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_function_guide_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_log_form_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_patterns_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_tracker_screen.dart';
import 'package:functional_parenting/features/toolkit/presentation/paywall_screen.dart';
import 'package:functional_parenting/features/tools/presentation/assessment_screen.dart';
import 'package:functional_parenting/features/tools/presentation/decision_tool_screen.dart';
import 'package:functional_parenting/features/tools/presentation/expert_feedback_screen.dart';
import 'package:functional_parenting/features/tools/presentation/saved_recommendations_screen.dart';
import 'package:functional_parenting/features/tools/presentation/scripts_screen.dart';
import 'package:functional_parenting/features/tools/presentation/tools_screen.dart';
import 'package:functional_parenting/features/tools/presentation/worksheet_screen.dart';
import 'package:functional_parenting/features/welcome/presentation/welcome_screen.dart';
import 'package:functional_parenting/features/workshops/presentation/workshops_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider);
  final introSeen = ref.read(introSeenProvider);
  final initialLocation = !introSeen
      ? '/welcome'
      : authNotifier.isLoggedIn
      ? '/today'
      : '/login';
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final onWelcome = state.matchedLocation == '/welcome';
      final introSeen = ref.read(introSeenProvider);
      final loggedIn = authNotifier.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';
      String? dest;
      if (!introSeen && !onWelcome) {
        // Intro carousel on first open (once per device) — before login.
        dest = '/welcome';
      } else if (!loggedIn && !onLogin && !onWelcome) {
        // Everything but the intro requires auth.
        dest = '/login';
      } else if (loggedIn && onLogin) {
        dest = '/today';
      } else if (state.matchedLocation.startsWith('/admin') &&
          !ref.read(isAdminProvider)) {
        dest = '/today';
      }
      return dest;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // First-login intro carousel — full screen, outside the shell chrome.
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      // Full-screen "Reset Right Now" experience — outside the shell chrome.
      GoRoute(path: '/reset', builder: (context, state) => const ResetScreen()),
      // Admin content CMS — full screen, gated in redirect above.
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      GoRoute(
        path: '/admin/workshops',
        builder: (context, state) => const WorkshopsAdminScreen(),
      ),
      // Account & password management — full screen.
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      // ── Pro toolkit (full-screen flows) ──────────────────────────────────
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/tools/tracker',
        builder: (context, state) => const BehaviorTrackerScreen(),
      ),
      GoRoute(
        path: '/tools/tracker/new',
        builder: (context, state) => const BehaviorLogFormScreen(),
      ),
      // Must precede '/tools/tracker/:id' so "patterns" isn't read as an id.
      GoRoute(
        path: '/tools/tracker/patterns',
        builder: (context, state) => const BehaviorPatternsScreen(),
      ),
      GoRoute(
        path: '/tools/tracker/:id',
        builder: (context, state) =>
            BehaviorLogFormScreen(logId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/tools/guide',
        builder: (context, state) => const BehaviorFunctionGuideScreen(),
      ),
      GoRoute(
        path: '/tools/saved',
        builder: (context, state) => const SavedRecommendationsScreen(),
      ),
      // Deep-link a single saved recommendation (full-screen, non-shell so it
      // can be pushed safely from the saved list).
      GoRoute(
        path: '/tools/recommendation/:leaf',
        builder: (context, state) =>
            DecisionToolScreen(initialLeafId: state.pathParameters['leaf']),
      ),
      // "What should I do?" expert-feedback page — full-screen so it pushes
      // cleanly from both the in-shell flow and the deep-linked result.
      GoRoute(
        path: '/tools/expert-feedback',
        builder: (context, state) => const ExpertFeedbackScreen(),
      ),
      GoRoute(
        path: '/tools/worksheet/:id',
        builder: (context, state) =>
            WorksheetScreen(worksheetId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tools/plans',
        builder: (context, state) => const ActionPlansScreen(),
      ),
      GoRoute(
        path: '/tools/plans/new',
        builder: (context, state) => const ActionPlanFormScreen(),
      ),
      GoRoute(
        path: '/tools/plans/:id/edit',
        builder: (context, state) =>
            ActionPlanFormScreen(planId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/tools/plans/:id',
        builder: (context, state) =>
            ActionPlanViewScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reflections',
        builder: (context, state) => const ReflectionsScreen(),
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
