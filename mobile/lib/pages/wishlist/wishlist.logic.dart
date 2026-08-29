import 'package:customer_app/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'wishlist.state.dart';
import '../../../services/api_service.dart';

part 'wishlist.logic.g.dart';

@riverpod
class WishlistLogic extends _$WishlistLogic {
  @override
  WishlistState build() {
    Future.microtask(() => load(isRefresh: true));
    return const WishlistState();
  }

  Future<void> load({bool isRefresh = false}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(isLoading: false, isError: true, errorMessage: 'User not logged in');
      return;
    }

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        projectIds: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.projectIds.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
      }
    }

    try {
      final response = await ApiService.fetchWishlistPagination(
        userId: uid,
        lastDocument: state.lastDocument,
        limit: 15,
      );

      final newIds = response.data.map((e) => e['id'] as String).toList();
      final combinedIds = isRefresh ? newIds : [...state.projectIds, ...newIds];
      
      state = state.copyWith(
        projectIds: combinedIds.toSet().toList(), // Ensure uniqueness
        lastDocument: response.lastDocument,
        hasMore: response.data.length == 15,
        isLoading: false,
        isFetchingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await load();
  }

  Future<void> toggleFavorite(String projectId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    final isCurrentlyFavorite = state.projectIds.contains(projectId);
    final isFavorite = !isCurrentlyFavorite;

    // Optimistic update
    final newList = List<String>.from(state.projectIds);
    if (isFavorite) {
      newList.add(projectId);
    } else {
      newList.remove(projectId);
    }
    state = state.copyWith(projectIds: newList);

    try {
      await ApiService.toggleWishlist(uid, projectId, isFavorite);
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        projectIds: isCurrentlyFavorite
            ? [...state.projectIds, projectId]
            : state.projectIds.where((id) => id != projectId).toList(),
      );
    }
  }
}
