import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/company_info.dart';

part 'contact.state.freezed.dart';

@freezed
sealed class ContactState with _$ContactState {
  const factory ContactState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    CompanyInfo? companyInfo,
  }) = _ContactState;
}
