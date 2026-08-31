import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/l10n_extension.dart';
import '../../../utils/validators.dart';
import 'login.logic.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;

    final state = ref.watch(loginLogicProvider);
    final logic = ref.read(loginLogicProvider.notifier);

    useValueListenable(emailController);
    useValueListenable(passwordController);

    final isFormFilled =
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;

    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) return;

      final success = await logic.login(
        emailController.text.trim(),
        passwordController.text.trim(),
        context,
      );
      if (success && context.mounted) {
        context.go('/home');
      }
    }

    return Scaffold(
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
                  onPressed: () => context.push('/forgot-password'),
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
                onPressed: () => context.push('/register'),
                child: Text(l10n.dontHaveAccount),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
