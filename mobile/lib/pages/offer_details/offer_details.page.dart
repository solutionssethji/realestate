import 'package:customer_app/widgets/generic_shimmer_loader.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'offer_details.logic.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';

class OfferDetailsPage extends HookConsumerWidget {
  final String offerId;

  const OfferDetailsPage({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offerDetailsLogicProvider(offerId));
    final offer = state.offer;
    final dateFormat = DateFormat('dd MMM yyyy');

    if (state.isLoading) {
      return Scaffold(
        appBar: PremiumAppBar(title: context.l10n.offerDetails),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerLoader(count: 3, height: 150),
        ),
      );
    }

    if (state.isError || offer == null) {
      return Scaffold(
        appBar: PremiumAppBar(title: context.l10n.offerDetails),
        body: Center(
          child: Text(state.errorMessage ?? context.l10n.offerNotFound),
        ),
      );
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.offerDetails),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                offer.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _OfferBadge(
                          text:
                              '${context.l10n.validText}: ${dateFormat.format(offer.startDate)} - ${dateFormat.format(offer.endDate)}',
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        _OfferBadge(
                          text: offer.status,
                          color: offer.status == 'ACTIVE'
                              ? AppTheme.success
                              : AppTheme.error,
                          backgroundColor:
                              (offer.status == 'ACTIVE'
                                      ? AppTheme.success
                                      : AppTheme.error)
                                  .withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      offer.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (offer.discountValue != null &&
                        offer.discountValue! > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        offer.discountType == 'FLAT'
                            ? '${context.l10n.flat} ₹${NumberFormat('#,##,###').format(offer.discountValue)} ${context.l10n.off}'
                            : '${offer.discountValue!.toInt()}% ${context.l10n.off}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.darkGold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    if (offer.offerCode?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.promoCode,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: AppTheme.info),
                                  ),
                                  Text(
                                    offer.offerCode!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppTheme.info,
                                          fontWeight: FontWeight.w900,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.copy, color: AppTheme.info),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.aboutTheOffer,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppTheme.black,
                      ),
                    ),
                    if (offer.projectId?.isNotEmpty == true) ...[
                      const Divider(height: 24),
                      Text(
                        context.l10n.applicableProject,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (offer.projectName?.isNotEmpty == true)
                        Text(
                          offer.projectName!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.black),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/project/${offer.projectId}'),
                          child: Text(context.l10n.viewProjectDetails),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;

  const _OfferBadge({
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
