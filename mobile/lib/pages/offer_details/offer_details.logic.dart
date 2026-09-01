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
    final offer = await ApiService.getOffer(offerId);
    if (offer == null) {
      throw Exception('Offer not found');
    }
    state = state.copyWith(isLoading: false, offer: offer);
  }
}
