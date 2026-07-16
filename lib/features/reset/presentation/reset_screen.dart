import 'package:flutter/material.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

/// "Reset Right Now" — a calm full-screen breathing + grounding sequence a
/// parent can open in a heated moment.
class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _phases = ['Breathe in', 'Hold', 'Breathe out', 'Hold'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => context.pop(),
              ),
            ),
            const Spacer(),
            const Text(
              'Reset Right Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your calm is the intervention.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 4; // 0..4 across the 4 phases
                final phase = t.floor() % 4;
                // Scale swells on inhale, shrinks on exhale.
                final local = t - t.floor();
                double scale;
                if (phase == 0) {
                  scale = 0.6 + 0.4 * local; // in
                } else if (phase == 1) {
                  scale = 1.0; // hold
                } else if (phase == 2) {
                  scale = 1.0 - 0.4 * local; // out
                } else {
                  scale = 0.6; // hold
                }
                return Column(
                  children: [
                    SizedBox(
                      height: 220,
                      width: 220,
                      child: Center(
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [kBlue, kSage],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kBlue.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _phases[phase],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Drop your shoulders. Unclench your jaw.\nYou can respond in a moment — there is no rush.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: kNavy,
                      ),
                      onPressed: () => context.pop(),
                      child: const Text("I'm ready"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
