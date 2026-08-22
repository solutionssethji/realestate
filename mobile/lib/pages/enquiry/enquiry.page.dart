import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'enquiry.logic.dart';
import '../../widgets/app_text_field.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class EnquiryPage extends HookConsumerWidget {
  final String? initialProjectId;

  const EnquiryPage({super.key, this.initialProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(enquiryLogicProvider);
    final logic = ref.read(enquiryLogicProvider.notifier);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameCtrl = useTextEditingController();
    final phoneCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final requirementCtrl = useTextEditingController();
    final budgetCtrl = useTextEditingController();
    final messageCtrl = useTextEditingController();

    return Scaffold(
      appBar: PremiumAppBar(title: loc.enquireNow),
      body: SingleChildScrollView(
        padding: AppSpacing.allLg,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: formKey,
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

                  // Name
                  AppTextField(
                    controller: nameCtrl,
                    label: loc.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.nameRequired
                        : null,
                  ),
                  AppSpacing.hLg,

                  // Phone
                  AppTextField(
                    controller: phoneCtrl,
                    label: loc.mobileNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? context.l10n.enterValidMobile
                        : null,
                  ),
                  AppSpacing.hLg,

                  // Email
                  AppTextField(
                    controller: emailCtrl,
                    label: loc.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  AppSpacing.hLg,

                  // Plot Requirement
                  AppTextField(
                    controller: requirementCtrl,
                    label: loc.plotRequirement,
                    prefixIcon: const Icon(Icons.landscape_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  AppSpacing.hLg,

                  // Budget
                  AppTextField(
                    controller: budgetCtrl,
                    label: loc.budget,
                    prefixIcon: const Icon(Icons.currency_rupee_outlined),
                    textInputAction: TextInputAction.next,
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
                    _Banner(
                      text: state.errorMessage ?? context.l10n.submissionFailed,
                      color: AppTheme.error,
                    ),
                    AppSpacing.hLg,
                  ],
                  if (state.isSuccess) ...[
                    _Banner(
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
                    onPressed: state.isSuccess || state.isSubmitting
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              logic.submitEnquiry(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
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

class _Banner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Banner({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.error_outline, color: color, size: 18),
          AppSpacing.wSm,
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
