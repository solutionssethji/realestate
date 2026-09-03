import 'package:customer_app/models/customer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import 'referred_users.state.dart';

part 'referred_users.logic.g.dart';

const _pageSize = 10;

@riverpod
class ReferredUsersLogic extends _$ReferredUsersLogic {
  @override
  ReferredUsersState build() {
    final customer = ref.watch(customerProvider);
    customer.whenData((c) {
      if (c != null) {
        Future.microtask(() => loadUsers(isRefresh: true));
      }
    });
    return const ReferredUsersState();
  }

  Future<void> loadUsers({bool isRefresh = false}) async {
    final customer = await ref.read(customerProvider.future);
    if (customer == null) return;

    final allIds = List<ReferredUser>.from(customer.referredUserIds);

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 0,
        users: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      state = state.copyWith(isFetchingMore: true);
    }

    final currentPage = isRefresh ? 0 : state.page;

    try {
      final newUsers = await ApiService.getReferredUsers(
        allIds,
        page: currentPage,
        limit: _pageSize,
      );

      state = state.copyWith(
        users: isRefresh ? newUsers : [...state.users, ...newUsers],
        page: currentPage + 1,
        hasMore: newUsers.length == _pageSize,
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
    await loadUsers();
  }
}
