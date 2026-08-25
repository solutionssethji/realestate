import 'package:freezed_annotation/freezed_annotation.dart';

part 'support.state.freezed.dart';

@freezed
sealed class SupportState with _$SupportState {
  const factory SupportState() = _SupportState;
}
