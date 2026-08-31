import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/login_required_state.dart';
import '../../theme/theme.dart';
import 'profile.logic.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(profileLogicProvider);
    final logic = ref.read(profileLogicProvider.notifier);
    final l10n = context.l10n;

    ref.listen(profileLogicProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: PremiumAppBar(
        title: l10n.myProfile,
        showBackButton: false,
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
                      await logic.logout();
                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                  ),
        ],
      ),
      body: user == null
          ? LoginRequiredState(
              message: l10n.notLoggedIn,
              buttonText: l10n.loginBtn,
              onLogin: () => context.push('/login'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'No Email',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(l10n.myProperties),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/my-properties'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text(l10n.kycAndDocuments),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/kyc'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(l10n.myEnquiries),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to enquiries
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(l10n.mySiteVisits),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to site visits
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.card_giftcard),
                  title: const Text('Referral & Rewards'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/referral'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: Text(l10n.supportCenter),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/support'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
    );
  }
}
