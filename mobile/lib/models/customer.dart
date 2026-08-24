import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String fullName,
    required String mobileNumber,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    // KYC Fields
    String? aadharNumber,
    String? aadharPhotoUrl,
    String? panNumber,
    String? panPhotoUrl,
    Map<String, dynamic>? bankDetails,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}
