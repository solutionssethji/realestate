import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'offers.state.dart';
import '../../../services/api_service.dart';

part 'offers.logic.g.dart';

@riverpod
class OffersLogic extends _$OffersLogic {
  @override
  OffersState build() {
    Future.microtask(() => loadOffers(isRefresh: true));
    return const OffersState();
  }

  Future<void> loadOffers({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        offers: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.offers.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
      }
    }

    try {
      final (newOffers, newLastDoc) = await ApiService.getOffers(
        lastDocument: state.lastDocument,
        limit: 10,
      );

      state = state.copyWith(
        offers: isRefresh ? newOffers : [...state.offers, ...newOffers],
        lastDocument: newLastDoc,
        hasMore: newOffers.length == 10,
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
    await loadOffers();
  }
}
