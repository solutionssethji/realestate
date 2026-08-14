import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/plot.dart';
import '../../../models/plot_status.dart';

part 'plot_availability.state.freezed.dart';

@freezed
sealed class PlotAvailabilityState with _$PlotAvailabilityState {
  const factory PlotAvailabilityState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    required String projectId,
    @Default([]) List<Plot> allPlots,
    @Default([]) List<Plot> filteredPlots,
    @Default('') String searchQuery,
    PlotStatus? selectedStatusFilter,
  }) = _PlotAvailabilityState;
}
