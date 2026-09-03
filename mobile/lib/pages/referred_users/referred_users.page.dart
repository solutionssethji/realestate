import 'package:customer_app/widgets/app_cached_image.dart';
import 'package:customer_app/widgets/generic_shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/empty_state.dart';
import 'referred_users.logic.dart';

class ReferredUsersPage extends HookConsumerWidget {
  const ReferredUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(referredUsersLogicProvider);
    final logic = ref.read(referredUsersLogicProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(title: l10n.invitesSent),
      body: SafeArea(child: _buildBody(context, ref, state, logic, l10n)),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, state, logic, l10n) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }

    if (state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }

    final users = state.users;
    if (users.isEmpty) {
      return EmptyState(
        icon: LucideIcons.users,
        title: l10n.noReferredUsersYet,
        message: l10n.noReferredUsersMessage,
        buttonText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => logic.loadUsers(isRefresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isFetchingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            logic.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: users.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == users.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildUserCard(context, users[index]);
          },
        ),
      ),
    );
  }

  // Generate a deterministic accent color from name initial
  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF355E70),
      const Color(0xFF2E7D6E),
      const Color(0xFF7B5EA7),
      const Color(0xFFB06A3A),
      const Color(0xFF2C6FAC),
      const Color(0xFF8C4B6E),
      const Color(0xFF4A7C59),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final fullName = user['fullName'] ?? user['name'] ?? 'Unknown User';
    final mobile = user['mobileNumber'] ?? user['phone'] ?? '';
    final email = user['email'] ?? '';
    final photoURL = user['photoURL'] as String?;
    final createdAt = user['createdAt'] as DateTime?;
    final locale = Localizations.localeOf(context);
    final dateStr = createdAt != null
        ? _formatDate(createdAt, locale)
        : context.l10n.unknownDate;
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final avatarBg = _avatarColor(fullName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: avatarBg.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatarBg.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: (photoURL != null && photoURL.isNotEmpty)
                  ? AppCachedImage(
                      imageUrl: photoURL,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: avatarBg,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (mobile.isNotEmpty && mobile != '—') ...[
                    const SizedBox(height: 4),
                    _infoRow(context, LucideIcons.phone, mobile),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    _infoRow(context, LucideIcons.mail, email, ellipsis: true),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Date badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.midnightNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.calendarDays,
                    size: 11,
                    color: AppTheme.midnightNavy.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.midnightNavy.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool ellipsis = false,
  }) {
    final child = Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppTheme.neutral500),
      overflow: ellipsis ? TextOverflow.ellipsis : null,
    );
    return Row(
      children: [
        Icon(icon, size: 12, color: AppTheme.neutral400),
        const SizedBox(width: 4),
        ellipsis ? Expanded(child: child) : child,
      ],
    );
  }

  String _formatDate(DateTime date, Locale locale) {
    if (locale.languageCode == 'hi') {
      final months = [
        'जन', 'फ़र', 'मार्च', 'अप्र', 'मई', 'जून',
        'जुल', 'अग', 'सित', 'अक्ट', 'नव', 'दिस'
      ];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}\n$hour:$minute $amPm';
    }
    return DateFormat('MMM dd, yyyy\nhh:mm a').format(date);
  }
}
