import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'plot_details.state.dart';
import '../../../services/api_service.dart';

part 'plot_details.logic.g.dart';

@riverpod
class PlotDetailsLogic extends _$PlotDetailsLogic {
  @override
  PlotDetailsState build(String projectId, String plotId) {
    loadPlotDetails(projectId, plotId);
    return const PlotDetailsState();
  }

  Future<void> loadPlotDetails(String projectId, String plotId) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final plots = await ApiService.getPlots(projectId);
      final plot = plots.firstWhere(
        (p) => p.id == plotId,
        orElse: () => throw Exception('Plot not found'),
      );
      state = state.copyWith(isLoading: false, plot: plot);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
