import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_enquiries.state.freezed.dart';

@freezed
sealed class MyEnquiriesState with _$MyEnquiriesState {
  const factory MyEnquiriesState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> enquiries,
  }) = _MyEnquiriesState;
}
