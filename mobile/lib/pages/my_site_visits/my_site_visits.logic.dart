import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import 'my_site_visits.state.dart';

part 'my_site_visits.logic.g.dart';

@riverpod
class MySiteVisitsLogic extends _$MySiteVisitsLogic {
  @override
  MySiteVisitsState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => loadVisits(user.uid));
    } else {
      return const MySiteVisitsState(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
    }
    return const MySiteVisitsState();
  }

  Future<void> loadVisits(String uid) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final data = await ApiService.getUserSiteVisits(uid);
      state = state.copyWith(visits: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
