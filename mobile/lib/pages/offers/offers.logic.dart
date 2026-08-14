import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'offers.state.dart';
import '../../../services/api_service.dart';

part 'offers.logic.g.dart';

@riverpod
class OffersLogic extends _$OffersLogic {
  @override
  OffersState build() {
    Future.microtask(() => loadOffers());
    return const OffersState();
  }

  Future<void> loadOffers() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final offers = await ApiService.getOffers();
      state = state.copyWith(isLoading: false, offers: offers);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
