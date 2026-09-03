import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/locale_provider.dart';
import '../../../theme/theme.dart';
import '../../../utils/l10n_extension.dart';
import '../../../utils/validators.dart';
import '../../../utils/snackbar_utils.dart';
import 'login.logic.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeControllerProvider);

    final state = ref.watch(loginLogicProvider);
    final logic = ref.read(loginLogicProvider.notifier);

    useValueListenable(emailController);
    useValueListenable(passwordController);

    ref.listen(loginLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        // Need to use AppSnackbar.showGlobalError since dialog might be open
        AppSnackbar.showGlobalError(next.errorMessage!);
      }
    });

    final isFormFilled =
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;

    Future<void> handleLogin() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      final success = await logic.login(
        emailController.text.trim(),
        passwordController.text.trim(),
        context,
      );
      if (success && context.mounted) {
        context.go(AppRoutes.home);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 4.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              onPressed: () => _showLanguageBottomSheet(
                context,
                ref,
                currentLocale.languageCode,
              ),
              icon: const Icon(Icons.language, size: 18),
              label: Text(
                currentLocale.languageCode == 'hi'
                    ? l10n.langHindi
                    : l10n.langEnglish,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  validator: (v) =>
                      AppValidators.required(context, v, l10n.emailLabel),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: passwordController,
                  label: l10n.passwordLabel,
                  obscureText: state.isObscure,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) =>
                      AppValidators.required(context, v, l10n.passwordLabel),
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
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),
                PremiumButton(
                  text: l10n.loginBtn,
                  onPressed: isFormFilled ? handleLogin : null,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: Text(l10n.dontHaveAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = context.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  ctx,
                  ref,
                  l10n.langEnglish,
                  'en',
                  currentLanguageCode == 'en',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  ctx,
                  ref,
                  l10n.langHindi,
                  'hi',
                  currentLanguageCode == 'hi',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String code,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(localeControllerProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : AppTheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : AppTheme.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
