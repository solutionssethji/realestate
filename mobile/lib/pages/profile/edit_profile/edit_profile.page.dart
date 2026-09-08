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
import '../../../widgets/app_cached_image.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
import 'edit_profile.logic.dart';
import '../../../utils/validators.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider);
    final customer = customerAsync.value;

    final nameController = useTextEditingController(
      text: customer?.fullName ?? '',
    );
    final emailController = useTextEditingController(
      text: customer?.email ?? '',
    );
    final profileImage = useState<XFile?>(null);
    final removeExistingPhoto = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;

    final state = ref.watch(editProfileLogicProvider);
    final logic = ref.read(editProfileLogicProvider.notifier);

    useValueListenable(nameController);
    useValueListenable(emailController);

    final isFormFilled =
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty;

    ref.listen(editProfileLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showError(context, next.errorMessage!);
      }
    });

    Future<void> handleUpdateProfile() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      final success = await logic.updateProfile(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        newProfileImage: profileImage.value,
        removeExistingPhoto: removeExistingPhoto.value,
        l10n: l10n,
      );

      if (success && context.mounted) {
        AppSnackbar.showSuccess(
          context,
          context.l10n.profileUpdatedSuccessfully,
        );
        context.pop();
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.editProfile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                              if (profileImage.value != null ||
                                  (customer?.photoURL != null &&
                                      customer!.photoURL!.isNotEmpty &&
                                      !removeExistingPhoto.value))
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: Text(l10n.removePhoto),
                                  onTap: () {
                                    profileImage.value = null;
                                    removeExistingPhoto.value = true;
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
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.neutral200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.midnightNavy.withValues(alpha: 0.2),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.midnightNavy.withValues(alpha: 0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: profileImage.value != null
                        ? Image.file(
                            File(profileImage.value!.path),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : (!removeExistingPhoto.value &&
                              customer?.photoURL != null &&
                              customer!.photoURL!.isNotEmpty)
                        ? AppCachedImage(
                            imageUrl: customer.photoURL!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => AppValidators.email(context, v),
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: context.l10n.saveChanges,
                onPressed: isFormFilled ? handleUpdateProfile : null,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
