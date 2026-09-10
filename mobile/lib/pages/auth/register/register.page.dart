import 'dart:developer';
import 'dart:io';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
import 'register.logic.dart';
import '../../../utils/validators.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../widgets/background_painters.widget.dart';
import '../../../main.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterPage extends HookConsumerWidget {
  final String? phoneNumber;
  final String? countryCode;

  const RegisterPage({super.key, this.phoneNumber, this.countryCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fallback to local storage if app was restarted
    final resolvedPhoneNumber =
        phoneNumber ?? appBox.get('userPhoneNumber') as String?;
    final resolvedCountryCode =
        countryCode ?? appBox.get('userCountryCode') as String?;
    log('resolvedPhoneNumber $resolvedPhoneNumber $resolvedCountryCode');
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final referralCodeController = useTextEditingController();
    final profileImage = useState<XFile?>(null);
    final termsAccepted = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;

    final state = ref.watch(registerLogicProvider);
    final logic = ref.read(registerLogicProvider.notifier);

    // Track field values for enabling the submit button
    useValueListenable(nameController);
    useValueListenable(emailController);

    final isFormFilled =
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        termsAccepted.value;

    // Listen to state changes to show errors
    ref.listen(registerLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showError(context, next.errorMessage!);
      }
    });

    Future<void> handleRegister() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      await logic.register(
        name: nameController.text.trim(),
        mobile: resolvedPhoneNumber ?? '',
        countryCode: resolvedCountryCode ?? '+91', // Fallback
        email: emailController.text.trim(),
        referralCode: referralCodeController.text.trim(),
        profileImage: profileImage.value,
        context: context,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PremiumAppBar(
        title: l10n.createAccount,
        showBackButton: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Stack(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bc) {
                              return SafeArea(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: Text(l10n.chooseFromGallery),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final picker = ImagePicker();
                                        final image = await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (image != null) {
                                          final croppedFile =
                                              await ImageCropper().cropImage(
                                                sourcePath: image.path,
                                                aspectRatio:
                                                    const CropAspectRatio(
                                                      ratioX: 1,
                                                      ratioY: 1,
                                                    ),
                                              );
                                          if (croppedFile != null) {
                                            profileImage.value = XFile(
                                              croppedFile.path,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_camera),
                                      title: Text(l10n.takeAPhoto),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final picker = ImagePicker();
                                        final image = await picker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                        if (image != null) {
                                          final croppedFile =
                                              await ImageCropper().cropImage(
                                                sourcePath: image.path,
                                                aspectRatio:
                                                    const CropAspectRatio(
                                                      ratioX: 1,
                                                      ratioY: 1,
                                                    ),
                                              );
                                          if (croppedFile != null) {
                                            profileImage.value = XFile(
                                              croppedFile.path,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    if (profileImage.value != null)
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: Text(l10n.removePhoto),
                                        onTap: () {
                                          profileImage.value = null;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.midnightNavy.withValues(
                                alpha: 0.2,
                              ),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.midnightNavy.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: AppTheme.white,
                            backgroundImage: profileImage.value != null
                                ? FileImage(File(profileImage.value!.path))
                                : null,
                            child: profileImage.value == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: AppTheme.midnightNavy,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: nameController,
                      label: l10n.fullName,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          AppValidators.required(context, v, l10n.fullName),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: emailController,
                      label: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => AppValidators.email(context, v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: referralCodeController,
                      label: l10n.referralCodeOptional,
                      prefixIcon: const Icon(Icons.group_add_outlined),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: termsAccepted.value,
                          onChanged: (value) => termsAccepted.value = value!,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall,
                              children: [
                                TextSpan(text: l10n.agreeToPrefix),
                                TextSpan(
                                  text: l10n.termsAndConditions,
                                  style: const TextStyle(
                                    color: AppTheme.midnightNavy,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse('https://example.com/terms'),
                                      );
                                    },
                                ),
                                TextSpan(text: l10n.agreeToAnd),
                                TextSpan(
                                  text: l10n.privacyPolicy,
                                  style: const TextStyle(
                                    color: AppTheme.midnightNavy,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse(
                                          'https://example.com/privacy',
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    PremiumButton(
                      text: l10n.signUp,
                      isLoading: state.isLoading,
                      onPressed: isFormFilled ? handleRegister : null,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }
}
