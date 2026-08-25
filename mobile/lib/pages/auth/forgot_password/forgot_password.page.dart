import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/l10n_extension.dart';
import 'forgot_password.logic.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final state = ref.watch(forgotPasswordLogicProvider);
    final logic = ref.read(forgotPasswordLogicProvider.notifier);
    final l10n = context.l10n;

    ref.listen(forgotPasswordLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    Future<void> handleReset() async {
      await logic.sendResetLink(emailController.text.trim());
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.forgotPasswordTitle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.resetPassword,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.resetPasswordDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading ? null : handleReset,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : Text(l10n.sendResetLink),
            ),
            if (state.isSent) ...[
              const SizedBox(height: 16),
              Text(
                l10n.resetLinkSent,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.backToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
