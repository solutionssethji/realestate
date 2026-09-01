import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile.state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _EditProfileState;
}
