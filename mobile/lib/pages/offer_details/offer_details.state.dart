import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/offer.dart';

part 'offer_details.state.freezed.dart';

@freezed
sealed class OfferDetailsState with _$OfferDetailsState {
  const factory OfferDetailsState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    Offer? offer,
  }) = _OfferDetailsState;
}
