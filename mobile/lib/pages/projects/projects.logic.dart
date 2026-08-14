import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'projects.state.dart';
import '../../../models/project.dart';
import '../../../services/api_service.dart';

part 'projects.logic.g.dart';

@riverpod
class ProjectsLogic extends _$ProjectsLogic {
  @override
  ProjectsState build() {
    loadProjects();
    return const ProjectsState();
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final projects = await ApiService.getProjects();
      state = state.copyWith(
        isLoading: false,
        allProjects: projects,
        filteredProjects: _filter(projects, state.searchQuery),
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
