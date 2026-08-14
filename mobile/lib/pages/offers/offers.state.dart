import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/offer.dart';

part 'offers.state.freezed.dart';

@freezed
sealed class OffersState with _$OffersState {
  const factory OffersState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Offer> offers,
  }) = _OffersState;
}
