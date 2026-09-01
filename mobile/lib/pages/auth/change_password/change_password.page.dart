import '../../../utils/l10n_extension.dart';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'change_password.logic.dart';
import '../../../utils/validators.dart';
import '../../../utils/snackbar_utils.dart';

class ChangePasswordPage extends HookConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final state = ref.watch(changePasswordLogicProvider);
    final logic = ref.read(changePasswordLogicProvider.notifier);

    useValueListenable(currentPasswordController);
    useValueListenable(newPasswordController);
    useValueListenable(confirmPasswordController);

    final isFormFilled = currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.length >= 6 &&
        confirmPasswordController.text.isNotEmpty;

    ref.listen(changePasswordLogicProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showError(context, next.errorMessage!);
      }
    });

    Future<void> handleChangePassword() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      if (newPasswordController.text != confirmPasswordController.text) {
        AppSnackbar.showError(context, context.l10n.passwordsDoNotMatch);
        return;
      }

      final success = await logic.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (success && context.mounted) {
        AppSnackbar.showSuccess(context, context.l10n.passwordChangedSuccessfully);
        context.pop();
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.changePassword),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              AppTextField(
                controller: currentPasswordController,
                label: context.l10n.currentPassword,
                obscureText: state.isCurrentPasswordObscure,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n.currentPasswordRequired;
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isCurrentPasswordObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => logic.toggleCurrentPasswordObscure(),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: newPasswordController,
                label: context.l10n.newPassword,
                obscureText: state.isNewPasswordObscure,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) => AppValidators.password(context, v),
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isNewPasswordObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => logic.toggleNewPasswordObscure(),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: confirmPasswordController,
                label: context.l10n.confirmNewPassword,
                obscureText: state.isConfirmPasswordObscure,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) {
                  if (v != newPasswordController.text) {
                    return context.l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isConfirmPasswordObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => logic.toggleConfirmPasswordObscure(),
                ),
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: context.l10n.updatePassword,
                onPressed: isFormFilled ? handleChangePassword : null,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
