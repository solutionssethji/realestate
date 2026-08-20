import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_info.freezed.dart';

@freezed
class CompanyInfo with _$CompanyInfo {
  const factory CompanyInfo({
    required String name,
    required String about,
    required String vision,
    required String mission,
    required List<String> whyChooseUs,
    required String officeAddress,
    required double latitude,
    required double longitude,
    required String phone,
    required String whatsapp,
    required String email,
    @Default('') String googleMapsUrl,
    @Default('') String contactNumberDisplay,
  }) = _CompanyInfo;
}
