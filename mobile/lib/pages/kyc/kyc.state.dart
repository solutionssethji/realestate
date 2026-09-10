import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc.state.freezed.dart';

@freezed
sealed class KycState with _$KycState {
  const factory KycState({
    @Default(false) bool isLoading,
    File? aadharImage,
    File? panImage,
  }) = _KycState;
}
