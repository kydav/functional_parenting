import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kBlue,
                child: Text(
                  auth.userInitials,
                  style: const TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (auth.userEmail.isNotEmpty)
                      Text(
                        auth.userEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upgrade card — the paid tiers live here.
          SoftCard(
            color: kNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, color: kSage),
                    const SizedBox(width: 8),
                    Text(
                      'Go further',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _PlanRow(
                  title: 'Starter Toolkit',
                  price: 'one-time',
                  desc:
                      'Full toolkit, ABC tracker, worksheets, reset audio library.',
                ),
                const Divider(color: Colors.white12, height: 24),
                _PlanRow(
                  title: 'Functional Parenting Course',
                  price: 'course',
                  desc:
                      '8 guided modules — video, audio, reflection, and planning tools.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kSage,
                      foregroundColor: kNavy,
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Purchases (in-app / RevenueCat) — coming next.',
                        ),
                      ),
                    ),
                    child: const Text('See plans'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (isAdmin) ...[
            const Eyebrow('Founder tools'),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.edit_note_rounded,
              label: 'Content CMS',
              onTap: () => context.push('/admin'),
            ),
            const SizedBox(height: 24),
          ],

          const Eyebrow('Settings'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Daily tip notifications',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _SettingsTile(
            icon: Icons.emoji_events_outlined,
            label: 'Daily challenge reminders',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Account & password',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            danger: true,
            onTap: () => auth.signOut(),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String title;
  final String price;
  final String desc;
  const _PlanRow({
    required this.title,
    required this.price,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kSage.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: kSage,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : kTextPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.chevron_right_rounded,
                        color: kTextSecondary,
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
