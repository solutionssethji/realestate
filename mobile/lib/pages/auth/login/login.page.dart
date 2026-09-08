import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../theme/theme.dart';

import '../../../widgets/background_painters.widget.dart';
import 'login.logic.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final phoneNumber = useState<String>('');
    final countryCode = useState<String>('');
    final completeNumber = useState<String>('');
    final isPhoneValid = useState<bool>(false);

    final state = ref.watch(loginLogicProvider);
    final logic = ref.read(loginLogicProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                    children: [
                      Image.asset('assets/logo_with_vtext.png', height: 100),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your mobile number to unlock exclusive real estate opportunities.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Form(
                        key: formKey,
                        child: IntlPhoneField(
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.midnightNavy.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.midnightNavy.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.midnightNavy,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          initialCountryCode: 'IN',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (phone) {
                            completeNumber.value = phone.completeNumber;
                            phoneNumber.value = phone.number;
                            countryCode.value = phone.countryCode;
                            Future.microtask(() {
                              isPhoneValid.value =
                                  formKey.currentState?.validate() ?? false;
                            });
                          },
                          onCountryChanged: (country) {
                            Future.microtask(() {
                              isPhoneValid.value =
                                  formKey.currentState?.validate() ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      PremiumButton(
                        text: "Send OTP",
                        isLoading: state.isLoading,
                        onPressed: isPhoneValid.value
                            ? () {
                                FocusScope.of(context).unfocus();
                                if (formKey.currentState!.validate() &&
                                    completeNumber.value.isNotEmpty) {
                                  logic.sendOtp(
                                    completeNumber.value,
                                    phoneNumber.value,
                                    countryCode.value,
                                    context,
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
