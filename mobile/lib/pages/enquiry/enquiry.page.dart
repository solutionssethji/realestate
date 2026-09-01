import 'package:customer_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'enquiry.logic.dart';
import '../../widgets/app_text_field.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/feedback_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/validators.dart';
import '../../utils/snackbar_utils.dart';

class EnquiryPage extends HookConsumerWidget {
  final String? initialProjectId;

  const EnquiryPage({super.key, this.initialProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(enquiryLogicProvider);
    final logic = ref.read(enquiryLogicProvider.notifier);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final requirementCtrl = useTextEditingController();
    final budgetCtrl = useTextEditingController();
    final messageCtrl = useTextEditingController();

    useValueListenable(requirementCtrl);
    useValueListenable(budgetCtrl);

    final isFormFilled =
        requirementCtrl.text.trim().isNotEmpty &&
        budgetCtrl.text.trim().isNotEmpty;

    ref.listen(enquiryLogicProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        AppSnackbar.showSuccess(context, context.l10n.enquirySubmitted);
        context.pop();
      }
    });

    return Scaffold(
      appBar: PremiumAppBar(title: loc.enquireNow),
      body: SingleChildScrollView(
        padding: AppSpacing.allLg,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.getInTouch,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.midnightNavy,
                    ),
                  ),
                  AppSpacing.hSm,
                  Text(
                    context.l10n.expertsWillContact,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  AppSpacing.hXXl,

                  // Plot Requirement
                  AppTextField(
                    controller: requirementCtrl,
                    label: loc.plotRequirement,
                    prefixIcon: const Icon(Icons.landscape_outlined),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        AppValidators.required(context, v, loc.plotRequirement),
                  ),
                  AppSpacing.hLg,

                  // Budget
                  AppTextField(
                    controller: budgetCtrl,
                    label: loc.budget,
                    prefixIcon: const Icon(Icons.currency_rupee_outlined),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        AppValidators.required(context, v, loc.budget),
                  ),
                  AppSpacing.hLg,

                  // Message
                  AppTextField(
                    controller: messageCtrl,
                    label: loc.message,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                  ),
                  AppSpacing.hXXl,

                  // Feedback banners
                  if (state.isError) ...[
                    FeedbackBanner(
                      text: state.errorMessage ?? context.l10n.submissionFailed,
                      color: AppTheme.error,
                    ),
                    AppSpacing.hLg,
                  ],
                  if (state.isSuccess) ...[
                    FeedbackBanner(
                      text: context.l10n.enquirySubmitted,
                      color: AppTheme.success,
                      icon: Icons.check_circle_outline,
                    ),
                    AppSpacing.hLg,
                  ],

                  PremiumButton(
                    text: state.isSuccess
                        ? context.l10n.submitted
                        : context.l10n.submitEnquiry,
                    isLoading: state.isSubmitting,
                    onPressed:
                        state.isSuccess || state.isSubmitting || !isFormFilled
                        ? null
                        : () {
                            final currentUser = AuthService.currentUser;
                            if (currentUser == null) {
                              AppSnackbar.showError(context, context.l10n.loginToSubmitEnquiry);
                              return;
                            }
                            if (formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              logic.submitEnquiry(
                                customerId: currentUser.uid,
                                plotRequirement: requirementCtrl.text.trim(),
                                budget: budgetCtrl.text.trim(),
                                projectId: initialProjectId,
                                message: messageCtrl.text.trim(),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
