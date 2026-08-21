import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'offers.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';

class OffersPage extends ConsumerWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(offersLogicProvider);
    final logic = ref.read(offersLogicProvider.notifier);
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.exclusiveOffers),
      body: SafeArea(
        child: state.isLoading
            ? ListView.separated(
                padding: AppSpacing.allLg,
                itemCount: 4,
                separatorBuilder: (_, __) => AppSpacing.hLg,
                itemBuilder: (_, __) => const OfferCardSkeleton(),
              )
            : state.isError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 40,
                      color: AppTheme.textSecondary,
                    ),
                    AppSpacing.hSm,
                    Text(
                      context.l10n.unableToLoadOffers,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.hLg,
                    OutlinedButton.icon(
                      onPressed: logic.loadOffers,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.tryAgain),
                    ),
                  ],
                ),
              )
            : state.offers.isEmpty
            ? EmptyState(
                icon: Icons.local_offer_outlined,
                title: context.l10n.noActiveOffers,
                message: context.l10n.checkBackSoon,
              )
            : RefreshIndicator(
                onRefresh: () => logic.loadOffers(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      logic.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: AppSpacing.allLg,
                    itemCount:
                        state.offers.length + (state.isFetchingMore ? 1 : 0),
                    separatorBuilder: (_, __) => AppSpacing.hLg,
                    itemBuilder: (context, index) {
                      if (index == state.offers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final offer = state.offers[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _OfferImage(
                                    imageUrl: offer.image,
                                    width: 200,
                                    height: null,
                                  ),
                                  Expanded(
                                    child: _OfferInfo(
                                      offer: offer,
                                      context: context,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _OfferImage(
                                    imageUrl: offer.image,
                                    width: double.infinity,
                                    height: 180,
                                  ),
                                  _OfferInfo(offer: offer, context: context),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

class _OfferImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const _OfferImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      height: height ?? 180,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: AppTheme.border),
        errorWidget: (_, __, ___) => const ColoredBox(
          color: AppTheme.border,
          child: Icon(
            Icons.image_outlined,
            color: AppTheme.textSecondary,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _OfferInfo extends StatelessWidget {
  final dynamic offer;
  final BuildContext context;

  const _OfferInfo({required this.offer, required this.context});

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return Padding(
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.softGold.withValues(alpha: 0.15),
              borderRadius: AppRadius.circularSm,
            ),
            child: Text(
              context.l10n.specialOffer,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppTheme.darkGold),
            ),
          ),
          AppSpacing.hSm,
          Text(
            offer.title,
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.hXs,
          Text(
            offer.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.hLg,
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppTheme.warning,
              ),
              AppSpacing.wXs,
              Text(
                context.l10n.validUntil(
                  DateFormat('d MMM yyyy').format(offer.endDate),
                ),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
