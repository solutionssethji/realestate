import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/company_info.dart';

part 'support.state.freezed.dart';

@freezed
sealed class SupportState with _$SupportState {
  const factory SupportState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    CompanyInfo? companyInfo,
  }) = _SupportState;
}
