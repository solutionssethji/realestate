import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/company_info.dart';

part 'about.state.freezed.dart';

@freezed
sealed class AboutState with _$AboutState {
  const factory AboutState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    CompanyInfo? companyInfo,
  }) = _AboutState;
}
