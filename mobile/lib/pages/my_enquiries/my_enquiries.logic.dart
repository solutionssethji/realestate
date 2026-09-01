import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import 'my_enquiries.state.dart';

part 'my_enquiries.logic.g.dart';

@riverpod
class MyEnquiriesLogic extends _$MyEnquiriesLogic {
  @override
  MyEnquiriesState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => loadEnquiries(user.uid));
    } else {
      return const MyEnquiriesState(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
    }
    return const MyEnquiriesState();
  }

  Future<void> loadEnquiries(String uid) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final data = await ApiService.getUserEnquiries(uid);
      state = state.copyWith(enquiries: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
