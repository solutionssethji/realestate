import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'projects.state.dart';
import '../../../models/project.dart';
import '../../../services/api_service.dart';

part 'projects.logic.g.dart';

@riverpod
class ProjectsLogic extends _$ProjectsLogic {
  @override
  ProjectsState build() {
    Future.microtask(() => loadProjects(isRefresh: true));
    return const ProjectsState();
  }

  Future<void> loadProjects({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        allProjects: [],
        filteredProjects: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.allProjects.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
      }
    }

    try {
      final (newProjects, newLastDoc) = await ApiService.getProjects(
        lastDocument: state.lastDocument,
        limit: 10,
      );

      final combinedProjects = isRefresh ? newProjects : [...state.allProjects, ...newProjects];
      
      state = state.copyWith(
        allProjects: combinedProjects,
        filteredProjects: _filter(combinedProjects, state.searchQuery),
        lastDocument: newLastDoc,
        hasMore: newProjects.length == 10,
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
    await loadProjects();
  }

  void updateSearch(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredProjects: _filter(state.allProjects, query),
    );
  }

  List<Project> _filter(List<Project> projects, String query) {
    if (query.isEmpty) return projects;
    final lowerQuery = query.toLowerCase();
    return projects
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.location.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
