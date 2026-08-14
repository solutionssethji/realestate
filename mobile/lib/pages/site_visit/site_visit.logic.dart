import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'site_visit.state.dart';
import '../../../services/api_service.dart';

part 'site_visit.logic.g.dart';

@riverpod
class SiteVisitLogic extends _$SiteVisitLogic {
  @override
  SiteVisitState build() {
    return const SiteVisitState();
  }

  Future<bool> bookVisit({
    required String name,
    required String phone,
    required String projectId,
    required DateTime date,
    required String time,
    String? message,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isError: false,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      await ApiService.submitSiteVisit({
        'name': name,
        'mobile': phone,
        'projectId': projectId,
        'preferredDate': date.toIso8601String(),
        'preferredTime': time,
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
}
