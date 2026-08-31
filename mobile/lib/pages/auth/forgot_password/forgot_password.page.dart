import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../utils/l10n_extension.dart';
import '../../../utils/validators.dart';
import 'forgot_password.logic.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final state = ref.watch(forgotPasswordLogicProvider);
    final logic = ref.read(forgotPasswordLogicProvider.notifier);
    final l10n = context.l10n;

    useValueListenable(emailController);
    final isFormFilled = emailController.text.trim().isNotEmpty;

    ref.listen(forgotPasswordLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    Future<void> handleReset() async {
      if (!formKey.currentState!.validate()) return;
      await logic.sendResetLink(emailController.text.trim());
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.forgotPasswordTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.resetPasswordDesc,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: emailController,
                  label: l10n.emailLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      AppValidators.required(context, v, l10n.emailLabel),
                ),
                const SizedBox(height: 24),
                PremiumButton(
                  text: l10n.sendResetLink,
                  onPressed: isFormFilled ? handleReset : null,
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
        ),
      ),
    );
  }
}
