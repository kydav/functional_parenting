import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/admin_provider.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/providers/theme_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final notif = ref.watch(notificationSettingsProvider);
    final notifCtrl = ref.read(notificationSettingsProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);

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
              GestureDetector(
                onTap: () => auth.signOut(),
                child: Row(
                  children: [
                    Text(
                      'Sign Out',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.logout_rounded, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upgrade card — the paid tiers live here.
          SoftCard(
            color: context.colors.brandFill,
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
                const _PlanRow(
                  title: 'Starter Toolkit',
                  price: 'one-time',
                  desc:
                      'Full toolkit, ABC tracker, worksheets, reset audio library.',
                ),
                const Divider(color: Colors.white12, height: 24),
                const _PlanRow(
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
            _SettingsTile(
              icon: Icons.event_available_outlined,
              label: 'Manage workshops',
              onTap: () => context.push('/admin/workshops'),
            ),
            const SizedBox(height: 24),
          ],

          const Eyebrow('Settings'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Daily tip notifications',
            trailing: Switch(
              value: notif.tipEnabled,
              onChanged: (v) => notifCtrl.setTipEnabled(value: v),
            ),
          ),
          _SettingsTile(
            icon: Icons.emoji_events_outlined,
            label: 'Daily challenge reminders',
            trailing: Switch(
              value: notif.challengeEnabled,
              onChanged: (v) => notifCtrl.setChallengeEnabled(value: v),
            ),
          ),
          _SettingsTile(
            icon: Icons.self_improvement,
            label: 'Past Reflections',
            onTap: () => context.push('/reflections'),
          ),
          _SettingsTile(
            icon: Icons.brightness_6_outlined,
            label: 'Appearance',
            trailing: Text(
              _themeLabel(themeMode),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            onTap: () => _pickTheme(context, ref, themeMode),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Account & password',
            onTap: () => context.push('/account'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            onTap: () {
              launchUrl(
                Uri.parse('https://auaha.app/functionalparenting/privacy'),
                mode: LaunchMode.inAppBrowserView,
              );
            },
          ),
        ],
      ),
    );
  }
}

String _themeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

void _pickTheme(BuildContext context, WidgetRef ref, ThemeMode current) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          for (final mode in ThemeMode.values)
            ListTile(
              title: Text(_themeLabel(mode)),
              trailing: current == mode
                  ? Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).set(mode);
                Navigator.pop(sheetContext);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
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
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.colors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
