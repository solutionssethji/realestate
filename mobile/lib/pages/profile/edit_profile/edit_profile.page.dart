import 'dart:io';
import 'package:customer_app/routes/app_routes.dart';
import 'package:customer_app/widgets/app_text_field.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../widgets/app_cached_image.dart';
import '../../../utils/l10n_extension.dart';
import '../../../theme/theme.dart';
import 'edit_profile.logic.dart';
import '../../../utils/validators.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../providers/auth_provider.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider);
    final customer = customerAsync.value;

    final nameController = useTextEditingController(
      text: customer?.fullName ?? '',
    );
    final mobileController = useTextEditingController(
      text: customer?.mobileNumber ?? '',
    );
    final profileImage = useState<XFile?>(null);
    final removeExistingPhoto = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final l10n = context.l10n;

    final state = ref.watch(editProfileLogicProvider);
    final logic = ref.read(editProfileLogicProvider.notifier);

    useValueListenable(nameController);
    useValueListenable(mobileController);

    final isFormFilled =
        nameController.text.trim().isNotEmpty &&
        mobileController.text.trim().length == 10;

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
        mobileNumber: mobileController.text.trim(),
        newProfileImage: profileImage.value,
        removeExistingPhoto: removeExistingPhoto.value,
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
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppTheme.neutral200,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: profileImage.value != null
                        ? Image.file(
                            File(profileImage.value!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : (!removeExistingPhoto.value &&
                              customer?.photoURL != null &&
                              customer!.photoURL!.isNotEmpty)
                        ? AppCachedImage(
                            imageUrl: customer.photoURL!,
                            width: 100,
                            height: 100,
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
                controller: mobileController,
                label: l10n.mobileNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (v) => AppValidators.phone(context, v),
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: context.l10n.saveChanges,
                onPressed: isFormFilled ? handleUpdateProfile : null,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.account,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                context,
                LucideIcons.fileBadge,
                l10n.kycAndDocuments,
                () => context.push(AppRoutes.kyc),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                Icons.lock_outline,
                l10n.changePassword,
                () => context.push(AppRoutes.changePassword),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
