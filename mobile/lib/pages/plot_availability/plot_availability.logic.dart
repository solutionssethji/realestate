import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'plot_availability.state.dart';
import '../../../models/plot_status.dart';
import '../../../services/api_service.dart';

part 'plot_availability.logic.g.dart';

@riverpod
class PlotAvailabilityLogic extends _$PlotAvailabilityLogic {
  @override
  PlotAvailabilityState build(String projectId) {
    Future.microtask(() => loadPlots(projectId));
    return PlotAvailabilityState(projectId: projectId);
  }

  Future<void> loadPlots(String projectId) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    var plots = await ApiService.getPlots(projectId);

    // Fallback: if the plots collection is empty, try to get them from the embedded project document
    if (plots.isEmpty) {
      final project = await ApiService.getProject(projectId);
      if (project != null && project.plots.isNotEmpty) {
        plots = project.plots;
      }
    }

    state = state.copyWith(
      isLoading: false,
      allPlots: plots,
      filteredPlots: plots,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setStatusFilter(PlotStatus? status) {
    state = state.copyWith(selectedStatusFilter: status);
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.searchQuery.toLowerCase();
    final status = state.selectedStatusFilter;

    var filtered = state.allPlots;

    if (query.isNotEmpty) {
      filtered = filtered
          .where((p) => p.plotNumber.toLowerCase().contains(query))
          .toList();
    }

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    state = state.copyWith(filteredPlots: filtered);
  }
}
