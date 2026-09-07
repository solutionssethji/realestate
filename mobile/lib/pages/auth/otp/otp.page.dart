import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../theme/theme.dart';
import '../../../widgets/background_painters.widget.dart';
import 'otp.logic.dart';

class OtpPage extends HookConsumerWidget {
  final String verificationId;
  final String phoneNumber;
  final String completeNumber;
  final String countryCode;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.completeNumber,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpCode = useState<String>('');
    final state = ref.watch(otpLogicProvider);
    final isLoading = state.isLoading;
    final logic = ref.read(otpLogicProvider.notifier);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.midnightNavy.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.midnightNavy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -MediaQuery.of(context).viewInsets.bottom,
              child: CustomPaint(painter: TopRightWavePainter()),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -MediaQuery.of(context).viewInsets.bottom,
              child: CustomPaint(painter: BottomRightCirclesPainter()),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -MediaQuery.of(context).viewInsets.bottom,
              child: CustomPaint(painter: BottomLeftDotsPainter()),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo_with_vtext.png', height: 100),
                      const SizedBox(height: 24),
                      Text(
                        'Secure Verification',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We've sent a 6-digit verification code to\n$completeNumber",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Pinput(
                        length: 6,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppTheme.midnightNavy,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => otpCode.value = value,
                        onCompleted: (pin) {
                          logic.verifyOtp(
                            verificationId,
                            pin,
                            phoneNumber,
                            countryCode,
                            context,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      PremiumButton(
                        text: "Verify & Continue",
                        isLoading: isLoading,
                        onPressed: () {
                          if (otpCode.value.length == 6) {
                            logic.verifyOtp(
                              verificationId,
                              otpCode.value,
                              phoneNumber,
                              countryCode,
                              context,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      HookBuilder(
                        builder: (context) {
                          final timeLeft = useState(30);
                          final timer = useRef<Timer?>(null);

                          void startTimer() {
                            timeLeft.value = 30;
                            timer.value?.cancel();
                            timer.value = Timer.periodic(
                              const Duration(seconds: 1),
                              (t) {
                                if (timeLeft.value > 0) {
                                  timeLeft.value--;
                                } else {
                                  t.cancel();
                                }
                              },
                            );
                          }

                          useEffect(() {
                            startTimer();
                            return () => timer.value?.cancel();
                          }, const []);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              timeLeft.value > 0
                                  ? Text(
                                      "Resend in ${timeLeft.value}s",
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              startTimer();
                                              logic.resendOtp(
                                                completeNumber,
                                                phoneNumber,
                                                countryCode,
                                                context,
                                              );
                                            },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Resend",
                                        style: TextStyle(
                                          color: AppTheme.midnightNavy,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: Text(
                          "Change Phone Number",
                          style: TextStyle(
                            color: AppTheme.midnightNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
