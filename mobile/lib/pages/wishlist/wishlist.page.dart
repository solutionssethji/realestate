import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'wishlist.logic.dart';
import '../../../widgets/property_card.dart';
import '../../../services/api_service.dart';
import '../../../models/project.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistLogicProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: wishlistState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistState.isError
          ? Center(
              child: Text(
                wishlistState.errorMessage ?? 'Error loading wishlist',
              ),
            )
          : wishlistState.projectIds.isEmpty
          ? const Center(child: Text('No favorite projects yet.'))
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
                        child: Center(child: CircularProgressIndicator()),
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
