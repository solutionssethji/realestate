import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';

@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    required String id,
    required String title,
    required String description,
    required String image,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    String? projectId,
    String? projectName,
  }) = _Offer;
}
