import '../../utils/app_dialogs.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_cached_image.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/login_required_state.dart';
import '../../theme/theme.dart';
import '../../utils/snackbar_utils.dart';
import 'profile.logic.dart';
import '../../routes/app_routes.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/locale_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final customerAsync = ref.watch(customerProvider);
    final customer = customerAsync.value;
    final state = ref.watch(profileLogicProvider);
    final logic = ref.read(profileLogicProvider.notifier);
    final locale = ref.watch(localeControllerProvider);
    final l10n = context.l10n;

    ref.listen(profileLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: PremiumAppBar(
        title: l10n.myProfile,
        showBackButton: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.globe),
          onPressed: () {
            AppDialogs.showLanguageBottomSheet(
              context,
              ref,
              locale.languageCode,
            );
          },
        ),
        actions: [
          if (user != null)
            state.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      final confirm =
                          await AppDialogs.showConfirmationBottomSheet(
                            context,
                            title: l10n.signOut,
                            message: l10n.logoutConfirmation,
                            confirmText: l10n.signOut,
                            cancelText: l10n.cancel,
                          );
                      if (confirm != true) return;

                      await logic.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
        ],
      ),
      body: user == null
          ? LoginRequiredState(
              message: l10n.notLoggedIn,
              buttonText: l10n.loginBtn,
              onLogin: () => context.push(AppRoutes.login),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(customerProvider);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppTheme.neutral200,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          (customer?.photoURL != null &&
                              customer!.photoURL!.isNotEmpty)
                          ? AppCachedImage(
                              imageUrl: customer.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.textSecondary,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customer?.fullName ??
                        user.displayName ??
                        context.l10n.noName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customer?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.quickActions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    context,
                    LucideIcons.history,
                    l10n.myEnquiries,
                    () {
                      context.push(AppRoutes.myEnquiries);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.mapPin,
                    l10n.mySiteVisits,
                    () {
                      context.push(AppRoutes.mySiteVisits);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.calculator,
                    l10n.emiCalculator,
                    () => context.push(AppRoutes.emiCalculator),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.account,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    context,
                    LucideIcons.user,
                    context.l10n.editProfile,
                    () => context.push(AppRoutes.editProfile),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.badge,
                    l10n.kycAndDocuments,
                    () => context.push(AppRoutes.kyc),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.gift,
                    l10n.referralRewards,
                    () => context.push(AppRoutes.referral),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.legalAndSupport,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    context,
                    LucideIcons.contact2,
                    l10n.supportCenter,
                    () => context.push(AppRoutes.support),
                  ),

                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.helpCircle,
                    l10n.faq,
                    () async {
                      final url = Uri.parse(AppConstants.faqsUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.fileText,
                    l10n.termsAndConditions,
                    () async {
                      final url = Uri.parse(AppConstants.termsConditionsUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.shield,
                    l10n.privacyPolicy,
                    () async {
                      final url = Uri.parse(AppConstants.privacyPolicyUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    LucideIcons.trash2,
                    // Hardcoded fallback if translation is not generated yet
                    l10n.deleteAccount,
                    () async {
                      final confirm =
                          await AppDialogs.showConfirmationBottomSheet(
                            context,
                            title: l10n.deleteAccount,
                            message: l10n.deleteAccountWarning,
                            confirmText: l10n.deleteAccount,
                            cancelText: l10n.cancel,
                            isDestructive: true,
                          );
                      if (confirm != true) return;

                      final uid = AuthService.currentUser?.uid;
                      if (uid != null) {
                        final properties =
                            await ApiService.fetchUserPropertiesPagination(
                              limit: 1,
                              uid: uid,
                            );
                        if (properties.data.isNotEmpty && context.mounted) {
                          AppSnackbar.showError(
                            context,
                            l10n.cannotDeleteAccountBooking,
                          );
                          return;
                        }
                      }

                      final success = await logic.deleteAccount();
                      if (success && context.mounted) {
                        context.go(AppRoutes.home);
                      } else if (!success && context.mounted) {
                        if (state.errorMessage?.contains(
                              'requires-recent-login',
                            ) ==
                            true) {
                          AppSnackbar.showError(
                            context,
                            'Please sign in again to delete your account.',
                          );
                          await logic.logout();
                          if (context.mounted) {
                            context.go(AppRoutes.login);
                          }
                        }
                      }
                    },
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: effectiveColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
