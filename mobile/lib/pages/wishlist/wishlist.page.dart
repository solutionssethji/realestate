import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'wishlist.logic.dart';
import '../../../widgets/property_card.dart';
import '../../../services/api_service.dart';
import '../../../models/project.dart';
import '../../../utils/l10n_extension.dart';
import '../../theme/spacing.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/app_loading_view.dart';

class WishlistPage extends HookConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistLogicProvider);
    final logic = ref.read(wishlistLogicProvider.notifier);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.myWishlist),
      body: wishlistState.isLoading
          ? SkeletonList(
              padding: AppSpacing.allMd,
              spacing: AppSpacing.sm,
              itemCount: 3,
              itemBuilder: (_, __) => const ProjectCardSkeleton(),
            )
          : wishlistState.isError
          ? Center(
              child: Text(
                wishlistState.errorMessage ?? context.l10n.wishlistLoadError,
              ),
            )
          : wishlistState.projectIds.isEmpty
          ? Center(child: Text(context.l10n.noFavoriteProjects))
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!wishlistState.isLoading &&
                    !wishlistState.isFetchingMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  logic.loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () => logic.load(isRefresh: true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final projectId = wishlistState.projectIds[index];
                          return FutureBuilder<Project?>(
                            future: ApiService.getProject(projectId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ProjectCardSkeleton(),
                                );
                              }
                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: PropertyCard(
                                  project: snapshot.data!,
                                  onTap: () {
                                    context.push('/home/project/${snapshot.data!.id}');
                                  },
                                ),
                              );
                            },
                          );
                        },
                        childCount: wishlistState.projectIds.length,
                      ),
                    ),
                    if (wishlistState.isFetchingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: AppLoadingView(size: 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
