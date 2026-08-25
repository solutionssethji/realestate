import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_properties.state.freezed.dart';

@freezed
sealed class MyPropertiesState with _$MyPropertiesState {
  const factory MyPropertiesState({
    @Default(true) bool isLoading,
    @Default([]) List<Map<String, dynamic>> properties,
    String? errorMessage,
  }) = _MyPropertiesState;
}
