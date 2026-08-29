import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import 'premium_button.dart';

class LoginRequiredState extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onLogin;

  const LoginRequiredState({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            AppSpacing.hLg,
            PremiumButton(text: buttonText, onPressed: onLogin),
          ],
        ),
      ),
    );
  }
}
