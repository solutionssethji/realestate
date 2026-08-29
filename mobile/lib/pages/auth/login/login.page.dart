import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/l10n_extension.dart';
import 'login.logic.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final l10n = context.l10n;

    final state = ref.watch(loginLogicProvider);
    final logic = ref.read(loginLogicProvider.notifier);

    // Listen to state changes to show errors
    ref.listen(loginLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (previous?.isResendingMail == true &&
          next.isResendingMail == false &&
          next.errorMessage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.resetLinkSent)));
      }

      if (next.unverifiedUser != null && previous?.unverifiedUser == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Consumer(
            builder: (context, ref, _) {
              final dialogState = ref.watch(loginLogicProvider);
              return AlertDialog(
                title: const Text('Email Verification Required'),
                content: const Text(
                  'Your account is not verified yet.\n\n'
                  'For security reasons, you must verify your email address before accessing the app.\n\n'
                  'Please check your inbox (and spam folder) for a verification link, or click below to receive a new one.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      logic.clearUnverifiedUser();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: dialogState.isResendingMail
                        ? null
                        : () => logic.resendVerificationEmail(),
                    icon: dialogState.isResendingMail
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mail_outline, size: 18),
                    label: const Text('Send Verification Mail'),
                  ),
                ],
              );
            },
          ),
        );
      }
    });

    Future<void> handleLogin() async {
      final success = await logic.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (success && context.mounted) {
        context.go('/home');
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.loginPageTitle, showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.welcomeBack,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: emailController,
              label: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: passwordController,
              label: l10n.passwordLabel,
              obscureText: state.isObscure,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => logic.toggleObscure(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(l10n.forgotPassword),
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: l10n.loginBtn,
              onPressed: handleLogin,
              isLoading: state.isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/register'),
              child: Text(l10n.dontHaveAccount),
            ),
          ],
        ),
      ),
    );
  }
}
