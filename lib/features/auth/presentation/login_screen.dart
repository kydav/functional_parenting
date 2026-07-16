import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignUp = useState(false);
    final name = useTextEditingController();
    final email = useTextEditingController();
    final password = useTextEditingController();
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      busy.value = true;
      error.value = null;
      try {
        final auth = ref.read(authNotifierProvider);
        if (isSignUp.value) {
          await auth.signUp(
            email: email.text.trim(),
            password: password.text,
            name: name.text.trim(),
          );
        } else {
          await auth.signIn(email: email.text.trim(), password: password.text);
        }
      } catch (e) {
        error.value = e.toString().replaceAll(RegExp(r'^\[.*?\]\s*'), '');
      } finally {
        busy.value = false;
      }
    }

    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/icon/icon_fg.png', height: 128),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kBlue, kSage]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'Functional Parenting',
                        style: TextStyle(
                          color: kNavy,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Calmer moments. Stronger relationships.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isSignUp.value) ...[
                          TextField(
                            controller: name,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Your name',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => submit(),
                        ),
                        if (error.value != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            error.value!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: busy.value ? null : submit,
                          child: busy.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isSignUp.value ? 'Create account' : 'Sign in',
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => isSignUp.value = !isSignUp.value,
                          child: Text(
                            isSignUp.value
                                ? 'Already have an account? Sign in'
                                : 'New here? Create a free account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
