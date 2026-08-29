import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'wishlist.state.freezed.dart';

@freezed
class WishlistState with _$WishlistState {
  const factory WishlistState({
    @Default(true) bool isLoading,
    @Default(false) bool hasLoaded,
    @Default(true) bool hasMore,
    @Default(false) bool isFetchingMore,
    @Default([]) List<String> projectIds,
    @Default(false) bool isError,
    String? errorMessage,
    DocumentSnapshot? lastDocument,
  }) = _WishlistState;
}
