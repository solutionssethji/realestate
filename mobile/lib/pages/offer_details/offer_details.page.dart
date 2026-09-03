import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/app_cached_image.dart';
import 'package:customer_app/widgets/generic_shimmer_loader.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/error_state.dart';
import 'package:customer_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


import 'offer_details.logic.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../routes/app_routes.dart';

class OfferDetailsPage extends HookConsumerWidget {
  final String offerId;

  const OfferDetailsPage({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offerDetailsLogicProvider(offerId));
    final offer = state.offer;
    final locale = Localizations.localeOf(context);

    if (state.isLoading) {
      return Scaffold(
        appBar: PremiumAppBar(title: context.l10n.offerDetails),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerLoader(count: 1, height: 250, borderRadius: 0),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoader(count: 1, height: 30, width: 200),
                    SizedBox(height: 16),
                    ShimmerLoader(count: 1, height: 40, width: double.infinity),
                    SizedBox(height: 16),
                    ShimmerLoader(count: 1, height: 80, width: double.infinity),
                    SizedBox(height: 16),
                    ShimmerLoader(
                      count: 3,
                      height: 20,
                      width: double.infinity,
                      spacing: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isError) {
      return Scaffold(
        appBar: PremiumAppBar(title: context.l10n.offerDetails),
        body: ErrorState(
          message: state.errorMessage,
          onRetry: () => ref
              .read(offerDetailsLogicProvider(offerId).notifier)
              .loadOffer(offerId),
        ),
      );
    }

    if (offer == null) {
      return Scaffold(
        appBar: PremiumAppBar(title: context.l10n.offerDetails),
        body: EmptyState(
          title: context.l10n.offerNotFound,
          message: context.l10n.offerNotFound,
          icon: Icons.local_offer_outlined,
        ),
      );
    }

    final startDate = formatDateOnly(offer.startDate, locale);
    final endDate = formatDateOnly(offer.endDate, locale);
    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.offerDetails),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCachedImage(
                imageUrl: offer.image,
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
                              '${context.l10n.validText}: $startDate - $endDate',
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      offer.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
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
                      if (offer.projectName?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          offer.projectName ?? '',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.black),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                            AppRoutes.projectDetails(offer.projectId ?? ""),
                          ),
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
