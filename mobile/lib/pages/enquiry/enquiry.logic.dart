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
    required String customerId,
    String? projectId,
    String? plotRequirement,
    String? budget,
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
        'customerId': customerId,
        if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
        if (plotRequirement != null && plotRequirement.isNotEmpty)
          'plotRequirement': plotRequirement,
        if (budget != null && budget.isNotEmpty) 'budget': budget,
        if (message != null && message.isNotEmpty) 'message': message,
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
