import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'my_properties.state.freezed.dart';

@freezed
abstract class MyPropertiesState with _$MyPropertiesState {
  const factory MyPropertiesState({
    @Default(true) bool isLoading,
    @Default(false) bool hasLoaded,
    @Default(true) bool hasMore,
    @Default(false) bool isFetchingMore,
    @Default([]) List<Map<String, dynamic>> properties,
    @Default(false) bool isError,
    String? errorMessage,
    DocumentSnapshot? lastDocument,
  }) = _MyPropertiesState;
}
