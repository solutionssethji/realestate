import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist.state.freezed.dart';

@freezed
sealed class WishlistState with _$WishlistState {
  const factory WishlistState({
    @Default(true) bool isLoading,
    @Default([]) List<String> projectIds,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _WishlistState;
}
