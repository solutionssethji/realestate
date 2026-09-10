import 'dart:io';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/premium_button.dart';
import 'package:customer_app/widgets/app_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/validators.dart';
import '../../utils/snackbar_utils.dart';
import '../../theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'kyc.logic.dart';

class KycPage extends HookConsumerWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);
    final customerAsync = ref.watch(customerProvider);
    final user = customerAsync.value;
    final kycState = ref.watch(kycLogicProvider);
    final kycLogic = ref.read(kycLogicProvider.notifier);

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

    final formKey = useMemoized(() => GlobalKey<FormState>());

    useValueListenable(aadharController);
    useValueListenable(panController);

    final hasAadharImg =
        kycState.aadharImage != null || (user?.aadharPhotoUrl != null);
    final hasPanImg = kycState.panImage != null || (user?.panPhotoUrl != null);

    final isFormFilled =
        aadharController.text.trim().isNotEmpty &&
        panController.text.trim().isNotEmpty &&
        hasAadharImg &&
        hasPanImg;

    Future<void> submitKyc() async {
      if (authUser == null) return;
      if (!formKey.currentState!.validate()) return;

      try {
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

        await kycLogic.submitKyc(
          uid: authUser.uid,
          aadharNumber: aadharController.text.trim(),
          panNumber: panController.text.trim(),
          bankDetails: bankDetails,
          currentAadharUrl: user?.aadharPhotoUrl,
          currentPanUrl: user?.panPhotoUrl,
        );

        if (context.mounted) {
          AppSnackbar.showSuccess(context, context.l10n.kycUpdatedSuccessfully);
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            context.l10n.failedToUpdateKyc(e.toString()),
          );
        }
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.kycAndDocuments),
      body: SafeArea(
        child: authUser == null || customerAsync.isLoading
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
                        imageFile: kycState.aadharImage,
                        existingUrl: user.aadharPhotoUrl,
                        onPickImage: () async {
                          try {
                            await kycLogic.pickDocument('aadhar');
                          } catch (e) {
                            if (context.mounted) {
                              AppSnackbar.showError(
                                context,
                                e.toString() == 'Exception: pdfTooLarge'
                                    ? context.l10n.pdfTooLarge
                                    : context.l10n.failedToPickImage(
                                        e.toString(),
                                      ),
                              );
                            }
                          }
                        },
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
                        imageFile: kycState.panImage,
                        existingUrl: user.panPhotoUrl,
                        onPickImage: () async {
                          try {
                            await kycLogic.pickDocument('pan');
                          } catch (e) {
                            if (context.mounted) {
                              AppSnackbar.showError(
                                context,
                                e.toString() == 'Exception: pdfTooLarge'
                                    ? context.l10n.pdfTooLarge
                                    : context.l10n.failedToPickImage(
                                        e.toString(),
                                      ),
                              );
                            }
                          }
                        },
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
                        validator: (v) => AppValidators.required(
                          context,
                          v,
                          context.l10n.bankName,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: accountController,
                        decoration: InputDecoration(
                          labelText: context.l10n.accountNumber,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            AppValidators.accountNumber(context, v),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ifscController,
                        decoration: InputDecoration(
                          labelText: context.l10n.ifscCode,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => AppValidators.ifscCode(context, v),
                        textCapitalization: TextCapitalization.characters,
                      ),

                      const SizedBox(height: 40),

                      PremiumButton(
                        text: context.l10n.saveDetails,
                        onPressed: isFormFilled ? submitKyc : null,
                        isLoading: kycState.isLoading,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildDocumentSection({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String hintText,
    required File? imageFile,
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
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onPickImage,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neutral100,
                          border: Border.all(
                            color: AppTheme.midnightNavy,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              imageFile != null || existingUrl != null
                                  ? Icons.check_circle
                                  : Icons.upload_file,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    imageFile != null
                                        ? imageFile.path.split('/').last
                                        : existingUrl != null
                                        ? l10n.fileSelected
                                        : l10n.tapToPickPdf,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (imageFile != null || existingUrl != null)
                                    Text(
                                      l10n.tapToChange,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            if (imageFile != null || existingUrl != null)
                              Icon(
                                Icons.edit,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (existingUrl != null) ...[
                    const SizedBox(width: 12),
                    PremiumButton(
                      text: l10n.viewPdf,
                      style: PremiumButtonStyle.outline,
                      isFullWidth: false,
                      onPressed: () async {
                        final uri = Uri.parse(existingUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
