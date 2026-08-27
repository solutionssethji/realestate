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

class WishlistPage extends HookConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistLogicProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.myWishlist),
      body: wishlistState.isLoading
          ? ListView.separated(
              padding: AppSpacing.allMd,
              itemCount: 3,
              separatorBuilder: (_, __) => AppSpacing.hSm,
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
          : ListView.builder(
              itemCount: wishlistState.projectIds.length,
              itemBuilder: (context, index) {
                final projectId = wishlistState.projectIds[index];
                return FutureBuilder<Project?>(
                  future: ApiService.getProject(projectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
            ),
    );
  }
}
