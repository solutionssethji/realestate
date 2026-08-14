import 'package:freezed_annotation/freezed_annotation.dart';
import 'customer.dart'; // For TimestampConverter

part 'customer_plot.freezed.dart';
part 'customer_plot.g.dart';

@freezed
class CustomerPlot with _$CustomerPlot {
  const factory CustomerPlot({
    required String id,
    required String customerId,
    required String projectId,
    required String plotId,
    required String status,
    @TimestampConverter() DateTime? purchaseDate,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _CustomerPlot;

  factory CustomerPlot.fromJson(Map<String, dynamic> json) =>
      _$CustomerPlotFromJson(json);
}
