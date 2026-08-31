import 'dart:io';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:customer_app/widgets/app_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/validators.dart';
import '../../theme/theme.dart';

class KycPage extends HookConsumerWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);
    final customerAsync = ref.watch(customerProvider);
    final user = customerAsync.value;
    final isLoading = useState(false);

    // Form controllers
    final aadharController = useTextEditingController(text: user?.aadharNumber);
    final panController = useTextEditingController(text: user?.panNumber);
    final bankNameController = useTextEditingController(
      text: user?.bankDetails?['bankName']?.toString(),
    );
    final accountController = useTextEditingController(
      text: user?.bankDetails?['accountNumber']?.toString(),
    );
    final ifscController = useTextEditingController(
      text: user?.bankDetails?['ifscCode']?.toString(),
    );

    // Selected images
    final aadharImage = useState<File?>(null);
    final panImage = useState<File?>(null);
    final picker = ImagePicker();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    useValueListenable(aadharController);
    useValueListenable(panController);

    final hasAadharImg = aadharImage.value != null || (user?.aadharPhotoUrl != null);
    final hasPanImg = panImage.value != null || (user?.panPhotoUrl != null);

    final isFormFilled = aadharController.text.trim().isNotEmpty &&
        panController.text.trim().isNotEmpty &&
        hasAadharImg && hasPanImg;

    Future<void> pickImage(ValueNotifier<File?> imageState) async {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (pickedFile != null) {
          imageState.value = File(pickedFile.path);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToPickImage(e.toString())),
            ),
          );
        }
      }
    }

    Future<void> submitKyc() async {
      if (authUser == null) return;
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      try {
        String? aadharUrl = user?.aadharPhotoUrl;
        String? panUrl = user?.panPhotoUrl;

        // Upload Aadhar
        if (aadharImage.value != null) {
          aadharUrl =
              await StorageService.uploadKycDocument(
                file: aadharImage.value!,
                documentType: 'aadhar',
              ) ??
              aadharUrl;
        }

        // Upload PAN
        if (panImage.value != null) {
          panUrl =
              await StorageService.uploadKycDocument(
                file: panImage.value!,
                documentType: 'pan',
              ) ??
              panUrl;
        }

        // Prepare bank details
        Map<String, dynamic> bankDetails = {};
        if (bankNameController.text.isNotEmpty ||
            accountController.text.isNotEmpty ||
            ifscController.text.isNotEmpty) {
          bankDetails = {
            'bankName': bankNameController.text.trim(),
            'accountNumber': accountController.text.trim(),
            'ifscCode': ifscController.text.trim(),
          };
        }

        await ApiService.updateKyc(
          uid: authUser.uid,
          aadharNumber: aadharController.text.trim(),
          aadharPhotoUrl: aadharUrl,
          panNumber: panController.text.trim(),
          panPhotoUrl: panUrl,
          bankDetails: bankDetails,
        );

        // Trigger user refresh if needed (customerProvider stream auto-updates)

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.kycUpdatedSuccessfully)),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToUpdateKyc(e.toString())),
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.kycAndDocuments),
      body: authUser == null || customerAsync.isLoading
          ? const AppLoadingView()
          : user == null
          ? Center(child: Text(context.l10n.userNotFound))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    context.l10n.identityDocuments,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Aadhar Section
                  _buildDocumentSection(
                    context: context,
                    title: context.l10n.aadharCard,
                    controller: aadharController,
                    hintText: context.l10n.enterAadharNumber,
                    imageState: aadharImage,
                    existingUrl: user.aadharPhotoUrl,
                    onPickImage: () => pickImage(aadharImage),
                    l10n: context.l10n,
                    validator: (v) => AppValidators.aadhaar(context, v),
                  ),

                  const SizedBox(height: 24),

                  // PAN Section
                  _buildDocumentSection(
                    context: context,
                    title: context.l10n.panCard,
                    controller: panController,
                    hintText: context.l10n.enterPanNumber,
                    imageState: panImage,
                    existingUrl: user.panPhotoUrl,
                    onPickImage: () => pickImage(panImage),
                    l10n: context.l10n,
                    validator: (v) => AppValidators.pan(context, v),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    context.l10n.bankDetails,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: bankNameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.bankName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: accountController,
                    decoration: InputDecoration(
                      labelText: context.l10n.accountNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ifscController,
                    decoration: InputDecoration(
                      labelText: context.l10n.ifscCode,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  PremiumButton(
                    text: context.l10n.saveDetails,
                    onPressed: isFormFilled ? submitKyc : null,
                    isLoading: isLoading.value,
                  ),
                  const SizedBox(height: 20),
                ],
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentSection({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String hintText,
    required ValueNotifier<File?> imageState,
    required String? existingUrl,
    required VoidCallback onPickImage,
    required dynamic l10n,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.uploadDocumentImage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  border: Border.all(
                    color: AppTheme.neutral300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageState.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(imageState.value!, fit: BoxFit.cover),
                      )
                    : existingUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(existingUrl, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.upload_file,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tapToPickImage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
