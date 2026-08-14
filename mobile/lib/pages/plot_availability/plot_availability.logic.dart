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
    try {
      final plots = await ApiService.getPlots(projectId);
      state = state.copyWith(
        isLoading: false,
        allPlots: plots,
        filteredPlots: plots,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
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
