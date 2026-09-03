import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import 'my_site_visits.state.dart';

part 'my_site_visits.logic.g.dart';

@riverpod
class MySiteVisitsLogic extends _$MySiteVisitsLogic {
  @override
  MySiteVisitsState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => loadVisits(isRefresh: true));
    } else {
      return const MySiteVisitsState(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
    }
    return const MySiteVisitsState();
  }

  Future<void> loadVisits({bool isRefresh = false}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        visits: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.visits.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
      }
    }

    try {
      final (newVisits, newLastDoc) = await ApiService.getUserSiteVisits(
        user.uid,
        lastDoc: state.lastDocument,
        limit: 10,
      );

      // Fetch project and plot names
      final projectIds = newVisits
          .map((e) => e['projectId'] as String?)
          .where((id) => id != null)
          .toSet();
      final plotIds = newVisits
          .map((e) => e['plotId'] as String?)
          .where((id) => id != null)
          .toSet();

      final projectNames = <String, String>{};
      final plotNames = <String, String>{};

      await Future.wait([
        ...projectIds.map((id) async {
          final project = await ApiService.getProject(id!);
          if (project != null) projectNames[id] = project.name;
        }),
        ...plotIds.map((id) async {
          final plot = await ApiService.getPlot(id!);
          if (plot != null) plotNames[id] = plot.plotNumber;
        }),
      ]);

      final enrichedVisits = newVisits.map((v) {
        final projectId = v['projectId'] as String?;
        final plotId = v['plotId'] as String?;
        return {
          ...v,
          if (projectId != null && projectNames.containsKey(projectId))
            'projectName': projectNames[projectId],
          if (plotId != null && plotNames.containsKey(plotId))
            'plotName': plotNames[plotId],
        };
      }).toList();

      state = state.copyWith(
        visits: isRefresh
            ? enrichedVisits
            : [...state.visits, ...enrichedVisits],
        lastDocument: newLastDoc,
        hasMore: newVisits.length == 10,
        isLoading: false,
        isFetchingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await loadVisits();
  }
}
