import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/providers/onboarding_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// One slide of the first-login intro carousel.
class _IntroSlide {
  final IconData icon;
  final Color accent;
  final String headline;
  final String body;
  const _IntroSlide({
    required this.icon,
    required this.accent,
    required this.headline,
    required this.body,
  });
}

/// The intro story, distilled from the toolkit welcome page: overwhelm →
/// reframe → the method → the goal.
const _slides = <_IntroSlide>[
  _IntroSlide(
    icon: Icons.cyclone_rounded,
    accent: kBlueDeep,
    headline: 'Sound familiar?',
    body:
        'You give a direction, it gets refused, everyone escalates — and by '
        'bedtime you’re wiped out.',
  ),
  _IntroSlide(
    icon: Icons.lightbulb_outline_rounded,
    accent: kSageDeep,
    headline: 'It’s not you',
    body:
        'When behavior is confusing, we react emotionally to a problem we '
        'don’t fully understand.',
  ),
  _IntroSlide(
    icon: Icons.explore_outlined,
    accent: kBlueDeep,
    headline: 'A calmer way',
    body:
        'Functional Parenting: understand why behavior happens, then respond '
        'with calm, clear structure.',
  ),
  _IntroSlide(
    icon: Icons.trending_up_rounded,
    accent: kSageDeep,
    headline: 'Teach, don’t just stop',
    body:
        'Build routines and skills that set your child up to succeed — '
        'instead of fighting the behavior.',
  ),
  _IntroSlide(
    icon: Icons.favorite_border_rounded,
    accent: kBlueDeep,
    headline: 'The goal isn’t perfection',
    body: 'It’s clarity, consistency, and confidence in your decisions.',
  ),
];

/// Full-screen, swipeable first-login intro. Shown once (gated by
/// [introSeenProvider] in the router); also reachable later as a replay.
class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final page = useState(0);
    final isLast = page.value == _slides.length - 1;

    void finish({required bool skipped}) {
      unawaited(ref.read(introSeenProvider.notifier).markSeen());
      unawaited(
        AnalyticsService.instance.logEvent(
          skipped ? 'intro_skipped' : 'intro_completed',
          {'slide': page.value},
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/today');
      }
    }

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: () => finish(skipped: true),
                  child: Text(
                    'Skip',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => page.value = i,
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            const SizedBox(height: 8),
            _Dots(count: _slides.length, active: page.value),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (isLast) {
                      finish(skipped: false);
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _IntroSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: slide.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 52, color: slide.accent),
          ),
          const SizedBox(height: 36),
          Text(
            slide.headline,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.55,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active
                  ? kNavy
                  : context.colors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
