import 'dart:io';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
import 'register.logic.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final mobileController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final profileImage = useState<XFile?>(null);
    final l10n = context.l10n;

    final state = ref.watch(registerLogicProvider);
    final logic = ref.read(registerLogicProvider.notifier);

    // Listen to state changes to show errors
    ref.listen(registerLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    Future<void> handleRegister() async {
      final success = await logic.register(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        profileImage: profileImage.value,
      );
      if (success && context.mounted) {
        // Wait briefly for auth state to propagate or navigate directly
        context.go('/home');
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.createAccount),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: mobileController,
              label: l10n.mobileNumber,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: emailController,
              label: l10n.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: passwordController,
              label: l10n.passwordLabel,
              obscureText: state.isObscure,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => logic.toggleObscure(),
              ),
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: l10n.register,
              onPressed: handleRegister,
              isLoading: state.isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/login'),
              child: Text(l10n.alreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }
}
