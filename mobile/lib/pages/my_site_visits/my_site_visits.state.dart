import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'my_site_visits.state.freezed.dart';

@freezed
sealed class MySiteVisitsState with _$MySiteVisitsState {
  const factory MySiteVisitsState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> visits,
    @Default(false) bool isFetchingMore,
    @Default(true) bool hasMore,
    DocumentSnapshot? lastDocument,
  }) = _MySiteVisitsState;
}
