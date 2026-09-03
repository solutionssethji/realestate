import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'my_enquiries.state.freezed.dart';

@freezed
sealed class MyEnquiriesState with _$MyEnquiriesState {
  const factory MyEnquiriesState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> enquiries,
    @Default(false) bool isFetchingMore,
    @Default(true) bool hasMore,
    DocumentSnapshot? lastDocument,
  }) = _MyEnquiriesState;
}
