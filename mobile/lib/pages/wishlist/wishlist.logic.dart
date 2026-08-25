import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'wishlist.state.dart';
import '../../../services/api_service.dart';

part 'wishlist.logic.g.dart';

@riverpod
class WishlistLogic extends _$WishlistLogic {
  @override
  WishlistState build() {
    Future.microtask(() => loadWishlist());
    return const WishlistState();
  }

  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        state = state.copyWith(isLoading: false, isError: true, errorMessage: 'User not logged in');
        return;
      }
      final items = await ApiService.getWishlist(uid);
      state = state.copyWith(isLoading: false, projectIds: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
    }
  }

  Future<void> toggleFavorite(String projectId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
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
      state = state.copyWith(projectIds: isCurrentlyFavorite 
          ? [...state.projectIds, projectId] 
          : state.projectIds.where((id) => id != projectId).toList());
    }
  }
}
