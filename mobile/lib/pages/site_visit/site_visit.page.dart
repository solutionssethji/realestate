import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'site_visit.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/premium_button.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class SiteVisitPage extends HookConsumerWidget {
  final String? initialProjectId;

  const SiteVisitPage({super.key, this.initialProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(siteVisitLogicProvider);
    final logic = ref.read(siteVisitLogicProvider.notifier);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameCtrl = useTextEditingController();
    final phoneCtrl = useTextEditingController();
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.bookSiteVisit),
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
                    context.l10n.scheduleTour,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.midnightNavy,
                    ),
                  ),
                  AppSpacing.hSm,
                  Text(
                    context.l10n.pickDateAndTime,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  AppSpacing.hXXl,

                  // Date Selector
                  _DateTimeSelector(
                    icon: Icons.calendar_today,
                    label: selectedDate.value == null
                        ? context.l10n.selectPreferredDate
                        : DateFormat(
                            'EEE, d MMM yyyy',
                          ).format(selectedDate.value!),
                    isSelected: selectedDate.value != null,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (date != null) selectedDate.value = date;
                    },
                  ),
                  AppSpacing.hLg,

                  // Time Selector
                  _DateTimeSelector(
                    icon: Icons.access_time_rounded,
                    label: selectedTime.value == null
                        ? context.l10n.selectPreferredTime
                        : selectedTime.value!.format(context),
                    isSelected: selectedTime.value != null,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 10, minute: 0),
                      );
                      if (time != null) selectedTime.value = time;
                    },
                  ),
                  AppSpacing.hXXl,

                  Text(
                    context.l10n.yourDetailsAlt,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  AppSpacing.hLg,

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

                  AppTextField(
                    controller: phoneCtrl,
                    label: loc.mobileNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? context.l10n.enterValidNumber
                        : null,
                  ),
                  AppSpacing.hXXl,

                  if (state.isError) ...[
                    _Banner(
                      text: state.errorMessage ?? context.l10n.bookingFailed,
                      color: AppTheme.error,
                    ),
                    AppSpacing.hLg,
                  ],
                  if (state.isSuccess) ...[
                    _Banner(
                      text: context.l10n.bookingConfirmedCall,
                      color: AppTheme.success,
                      icon: Icons.check_circle_outline,
                    ),
                    AppSpacing.hLg,
                  ],

                  PremiumButton(
                    text: state.isSuccess
                        ? context.l10n.bookingConfirmed
                        : context.l10n.confirmSiteVisit,
                    isLoading: state.isSubmitting,
                    icon: state.isSuccess
                        ? null
                        : Icons.directions_car_outlined,
                    onPressed: state.isSuccess || state.isSubmitting
                        ? null
                        : () {
                            if (selectedDate.value == null ||
                                selectedTime.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.pleaseSelectDateAndTime),
                                ),
                              );
                              return;
                            }
                            if (formKey.currentState!.validate()) {
                              final dt = DateTime(
                                selectedDate.value!.year,
                                selectedDate.value!.month,
                                selectedDate.value!.day,
                                selectedTime.value!.hour,
                                selectedTime.value!.minute,
                              );
                              logic.bookVisit(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                projectId: initialProjectId ?? '',
                                date: dt,
                                time: selectedTime.value!.format(context),
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

class _DateTimeSelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateTimeSelector({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.circularMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.midnightNavy.withValues(alpha: 0.04)
              : AppTheme.surface,
          border: Border.all(
            color: isSelected ? AppTheme.midnightNavy : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: AppRadius.circularMd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.midnightNavy
                  : AppTheme.textSecondary,
            ),
            AppSpacing.wLg,
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.midnightNavy
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected
                  ? AppTheme.midnightNavy
                  : AppTheme.textSecondary,
            ),
          ],
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
