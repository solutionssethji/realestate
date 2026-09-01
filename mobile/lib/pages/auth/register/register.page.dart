import 'dart:io';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
import '../../../constants.dart';
import 'register.logic.dart';
import '../../../utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/snackbar_utils.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final mobileController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final referralCodeController = useTextEditingController();
    final profileImage = useState<XFile?>(null);
    final termsAccepted = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;

    final state = ref.watch(registerLogicProvider);
    final logic = ref.read(registerLogicProvider.notifier);

    // Track field values for enabling the submit button
    useValueListenable(nameController);
    useValueListenable(mobileController);
    useValueListenable(emailController);
    useValueListenable(passwordController);
    useValueListenable(referralCodeController);

    final isFormFilled =
        nameController.text.trim().isNotEmpty &&
        mobileController.text.trim().length == 10 &&
        passwordController.text.trim().length >= 6 &&
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

      final success = await logic.register(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        referralCode: referralCodeController.text.trim(),
        profileImage: profileImage.value,
      );
      if (success && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.registrationSuccessTitle),
              content: Text(l10n.registrationSuccessMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.login);
                  },
                  child: Text(l10n.backToLogin),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.createAccount),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.joinUs,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                                    final croppedFile = await ImageCropper()
                                        .cropImage(
                                          sourcePath: image.path,
                                          aspectRatio: const CropAspectRatio(
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
                                    final croppedFile = await ImageCropper()
                                        .cropImage(
                                          sourcePath: image.path,
                                          aspectRatio: const CropAspectRatio(
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.neutral200,
                    backgroundImage: profileImage.value != null
                        ? FileImage(File(profileImage.value!.path))
                        : null,
                    child: profileImage.value == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: AppTheme.textSecondary,
                          )
                        : null,
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
                controller: mobileController,
                label: l10n.mobileNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (v) => AppValidators.phone(context, v),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                label: l10n.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => AppValidators.email(context, v),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordController,
                label: l10n.passwordLabel,
                obscureText: state.isObscure,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) => AppValidators.password(context, v),
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => logic.toggleObscure(),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: referralCodeController,
                label: context.l10n.referralCodeOptional,
                prefixIcon: const Icon(Icons.card_giftcard),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: termsAccepted.value,
                      onChanged: (val) {
                        termsAccepted.value = val ?? false;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        termsAccepted.value = !termsAccepted.value;
                      },
                      child: Text.rich(
                        TextSpan(
                          text: l10n.agreeToPrefix,
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: l10n.termsAndConditions,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(AppConstants.termsConditionsUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                            TextSpan(text: l10n.agreeToAnd),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(AppConstants.privacyPolicyUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                            if (l10n.agreeToSuffix.isNotEmpty)
                              TextSpan(text: l10n.agreeToSuffix),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: l10n.register,
                onPressed: isFormFilled ? handleRegister : null,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push(AppRoutes.login),
                child: Text(l10n.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
