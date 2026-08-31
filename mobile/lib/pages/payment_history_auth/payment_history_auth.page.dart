import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/spacing.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/validators.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/app_text_field.dart';

class PaymentHistoryAuthPage extends HookConsumerWidget {
  const PaymentHistoryAuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = useTextEditingController();
    final otpController = useTextEditingController();
    final isLoading = useState(false);
    final verificationId = useState<String?>(null);
    final errorMessage = useState<String?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final loc = AppLocalizations.of(context);

    useValueListenable(phoneController);
    useValueListenable(otpController);

    final isPhoneFilled = phoneController.text.trim().length == 10;
    final isOtpFilled = otpController.text.trim().length == 6;

    Future<void> sendOtp() async {
      if (!formKey.currentState!.validate()) return;
      final phone = phoneController.text.trim();
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      isLoading.value = true;
      errorMessage.value = null;
      try {
        await AuthService.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted: (credential) async {
            await AuthService.signInWithCredential(credential);
            if (!context.mounted) return;
            context.go('/payment-history');
          },
          verificationFailed: (e) {
            isLoading.value = false;
            errorMessage.value = e.message ?? loc.verificationFailed;
          },
          codeSent: (id, _) {
            isLoading.value = false;
            verificationId.value = id;
          },
          codeAutoRetrievalTimeout: (id) => verificationId.value = id,
        );
      } catch (_) {
        isLoading.value = false;
        errorMessage.value = loc.anErrorOccurred;
      }
    }

    Future<void> verifyOtp() async {
      if (!formKey.currentState!.validate()) return;
      final otp = otpController.text.trim();
      final id = verificationId.value;
      if (otp.isEmpty || id == null) return;
      isLoading.value = true;
      errorMessage.value = null;
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: id,
          smsCode: otp,
        );
        await AuthService.signInWithCredential(credential);
        if (!context.mounted) return;
        context.go('/payment-history');
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        errorMessage.value = e.message ?? loc.invalidOtp;
      } catch (_) {
        isLoading.value = false;
        errorMessage.value = loc.anErrorOccurred;
      }
    }

    final isOtpSent = verificationId.value != null;
    return Scaffold(
      appBar: PremiumAppBar(title: loc.verifyToViewHistory),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: AppSpacing.allLg,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const Icon(
                LucideIcons.shieldCheck,
                size: 64,
                color: AppTheme.midnightNavy,
              ),
              AppSpacing.hLg,
              Text(
                context.l10n.secureAccess,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppSpacing.hSm,
              Text(
                isOtpSent
                    ? context.l10n.enterOtpSent
                    : context.l10n.enterPhoneForHistory,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              AppSpacing.hXXl,
              if (errorMessage.value != null) ...[
                Container(
                  padding: AppSpacing.allMd,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularSm,
                  ),
                  child: Text(
                    errorMessage.value!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                AppSpacing.hMd,
              ],
              if (!isOtpSent) ...[
                AppTextField(
                  controller: phoneController,
                  label: loc.phoneNumber,
                  hint: 'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: (v) => AppValidators.phone(context, v),
                ),
                AppSpacing.hLg,
                PremiumButton(
                  text: context.l10n.sendOtp,
                  isLoading: isLoading.value,
                  onPressed: isPhoneFilled ? sendOtp : null,
                ),
              ] else ...[
                AppTextField(
                  controller: otpController,
                  label: loc.sixDigitOtp,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return 'Enter 6-digit OTP';
                    }
                    return null;
                  },
                ),
                AppSpacing.hLg,
                PremiumButton(
                  text: context.l10n.verify,
                  isLoading: isLoading.value,
                  onPressed: isOtpFilled ? verifyOtp : null,
                ),
                AppSpacing.hMd,
                TextButton(
                  onPressed: () {
                    verificationId.value = null;
                    otpController.clear();
                  },
                  child: Text(loc.changePhoneNumber),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    ),
  );
  }
}
