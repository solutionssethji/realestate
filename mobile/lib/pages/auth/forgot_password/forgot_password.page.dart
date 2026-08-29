import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.resetPasswordDesc,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: emailController,
              label: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: l10n.sendResetLink,
              onPressed: handleReset,
              isLoading: state.isLoading,
            ),
            if (state.isSent) ...[
              const SizedBox(height: 16),
              Text(
                l10n.resetLinkSent,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.success,
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
