import 'package:freezed_annotation/freezed_annotation.dart';
import 'plot_status.dart';

part 'plot.freezed.dart';

@freezed
class Plot with _$Plot {
  const factory Plot({
    required String id,
    required String projectId,
    required String plotNumber,
    required double sizeInSqFt,
    required String dimensions,
    required String facing,
    required String roadWidth,
    required PlotStatus status,
    required double price,
  }) = _Plot;
}
