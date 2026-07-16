import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final nameCtrl = useTextEditingController(text: auth.userName);
    final savingName = useState(false);

    Future<void> saveName() async {
      final messenger = ScaffoldMessenger.of(context);
      final name = nameCtrl.text.trim();
      if (name.isEmpty) return;
      savingName.value = true;
      try {
        await ref.read(authNotifierProvider).updateDisplayName(name);
        messenger.showSnackBar(const SnackBar(content: Text('Name updated.')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
      } finally {
        savingName.value = false;
      }
    }

    Future<void> sendReset() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(authNotifierProvider).sendPasswordReset(auth.userEmail);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${auth.userEmail}.'),
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not send email: $e')),
        );
      }
    }

    Future<void> deleteAccount() async {
      final messenger = ScaffoldMessenger.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This permanently deletes your account and your saved data. '
            "This can't be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      try {
        await ref.read(authNotifierProvider).deleteAccount();
        // Auth state change routes back to /login automatically.
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'For your security, please sign out and sign back in, then try '
                'deleting again.',
              ),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text('Could not delete account: ${e.message}')),
          );
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Account & password')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Your name'),
            const SizedBox(height: 10),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: savingName.value ? null : saveName,
                      child: savingName.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Eyebrow('Email'),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: kTextSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      auth.userEmail.isEmpty ? '—' : auth.userEmail,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Eyebrow('Password'),
            const SizedBox(height: 10),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "We'll email you a secure link to reset your password.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: auth.userEmail.isEmpty ? null : sendReset,
                    icon: const Icon(Icons.lock_reset_rounded, size: 18),
                    label: const Text('Send password reset email'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Eyebrow('Danger zone'),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              onTap: () => ref.read(authNotifierProvider).signOut(),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.delete_forever_rounded,
              label: 'Delete account',
              danger: true,
              onTap: deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : kTextPrimary;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const Icon(Icons.chevron_right_rounded, color: kTextSecondary),
        ],
      ),
    );
  }
}
