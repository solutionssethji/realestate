import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'offer_details.state.dart';
import '../../../services/api_service.dart';

part 'offer_details.logic.g.dart';

@riverpod
class OfferDetailsLogic extends _$OfferDetailsLogic {
  @override
  OfferDetailsState build(String offerId) {
    Future.microtask(() => loadOffer(offerId));
    return const OfferDetailsState();
  }

  Future<void> loadOffer(String offerId) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final offer = await ApiService.getOffer(offerId);
      state = state.copyWith(isLoading: false, offer: offer);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}
