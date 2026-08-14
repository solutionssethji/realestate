import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class PaymentHistoryAuthPage extends ConsumerStatefulWidget {
  const PaymentHistoryAuthPage({super.key});

  @override
  ConsumerState<PaymentHistoryAuthPage> createState() =>
      _PaymentHistoryAuthPageState();
}

class _PaymentHistoryAuthPageState
    extends ConsumerState<PaymentHistoryAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Add country code if missing
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (usually Android)
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            context.go('/payment-history');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? context.l10n.verificationFailed;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.anErrorOccurred;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        context.go('/payment-history');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? context.l10n.invalidOtp;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.anErrorOccurred;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isOtpSent = _verificationId != null;

    return Scaffold(
      appBar: PremiumAppBar(title: loc.verifyToViewHistory),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: AppSpacing.allLg,
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

              if (_errorMessage != null) ...[
                Container(
                  padding: AppSpacing.allMd,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularSm,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),
                AppSpacing.hMd,
              ],

              if (!isOtpSent) ...[
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: loc.phoneNumber,
                    hintText: 'e.g. 9876543210',
                    prefixText: '+91 ',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                AppSpacing.hLg,
                PremiumButton(
                  text: context.l10n.sendOtp,
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(labelText: loc.sixDigitOtp),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                AppSpacing.hLg,
                PremiumButton(
                  text: context.l10n.verify,
                  isLoading: _isLoading,
                  onPressed: _verifyOtp,
                ),
                AppSpacing.hMd,
                TextButton(
                  onPressed: () {
                    setState(() {
                      _verificationId = null;
                      _otpController.clear();
                    });
                  },
                  child: Text(loc.changePhoneNumber),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
