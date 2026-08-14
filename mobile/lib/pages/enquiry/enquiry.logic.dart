import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'enquiry.state.dart';
import '../../../services/api_service.dart';

part 'enquiry.logic.g.dart';

@riverpod
class EnquiryLogic extends _$EnquiryLogic {
  @override
  EnquiryState build() {
    return const EnquiryState();
  }

  Future<bool> submitEnquiry({
    required String name,
    required String phone,
    String? projectId,
    String? plotRequirement,
    String? message,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isError: false,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      await ApiService.submitEnquiry({
        'name': name,
        'mobile': phone,
        'projectId': projectId,
        'plotRequirement': plotRequirement,
        'budget':
            message, // or mapping budget differently, but since we have a message field, let's map it.
      });
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const EnquiryState();
  }
}
