import 'package:customer_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'site_visit.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/snackbar_utils.dart';
import 'package:go_router/go_router.dart';

class SiteVisitPage extends HookConsumerWidget {
  final String? initialProjectId;

  const SiteVisitPage({super.key, this.initialProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(siteVisitLogicProvider);
    final logic = ref.read(siteVisitLogicProvider.notifier);

    ref.listen(siteVisitLogicProvider, (previous, next) {
      if (next.isSuccess && (previous == null || !previous.isSuccess)) {
        AppSnackbar.showGlobalSuccess(context.l10n.bookingConfirmedCall);
        context.pop();
      }
      if (next.isError && (previous == null || !previous.isError)) {
        AppSnackbar.showError(
          context,
          next.errorMessage ?? context.l10n.bookingFailed,
        );
      }
    });

    final formKey = useMemoized(() => GlobalKey<FormState>());
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

                  PremiumButton(
                    text: context.l10n.confirmSiteVisit,
                    isLoading: state.isSubmitting,
                    icon: Icons.directions_car_outlined,
                    onPressed:
                        state.isSubmitting ||
                            selectedDate.value == null ||
                            selectedTime.value == null
                        ? null
                        : () {
                            final currentUser = AuthService.currentUser;
                            if (currentUser == null) {
                              AppSnackbar.showError(
                                context,
                                context.l10n.loginToBookSiteVisit,
                              );
                              return;
                            }
                            if (selectedDate.value == null ||
                                selectedTime.value == null) {
                              AppSnackbar.showError(
                                context,
                                loc.pleaseSelectDateAndTime,
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
                                customerId: currentUser.uid,
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
