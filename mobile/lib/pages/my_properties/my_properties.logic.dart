import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'my_properties.state.dart';

part 'my_properties.logic.g.dart';

@riverpod
class MyPropertiesLogic extends _$MyPropertiesLogic {
  @override
  MyPropertiesState build() {
    Future.microtask(() => load(isRefresh: true));
    return const MyPropertiesState();
  }

  Future<void> load({bool isRefresh = false}) async {
    final user = AuthService.currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
      return;
    }

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        properties: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.properties.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
      }
    }

    final response = await ApiService.fetchUserPropertiesPagination(
      uid: user.uid,
      lastDocument: state.lastDocument,
      limit: 15,
    );

    final combinedProperties = isRefresh
        ? response.data
        : [...state.properties, ...response.data];

    state = state.copyWith(
      properties: combinedProperties,
      lastDocument: response.lastDocument,
      hasMore: response.data.length == 15,
      isLoading: false,
      isFetchingMore: false,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await load();
  }
}
