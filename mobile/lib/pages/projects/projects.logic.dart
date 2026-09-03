import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'projects.state.dart';
import '../../../services/api_service.dart';

part 'projects.logic.g.dart';

@Riverpod(keepAlive: true)
class ProjectsLogic extends _$ProjectsLogic {
  Timer? _debounce;

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
        state = state.copyWith(
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
      }
    }

    final (newProjects, newLastDoc) = await ApiService.getProjects(
      lastDocument: state.lastDocument,
      limit: 10,
      searchQuery: state.searchQuery,
    );

    final combinedProjects = isRefresh
        ? newProjects
        : [...state.allProjects, ...newProjects];

    state = state.copyWith(
      allProjects: combinedProjects,
      filteredProjects: combinedProjects, // No more client-side filtering
      lastDocument: newLastDoc,
      hasMore: newProjects.length == 10,
      isLoading: false,
      isFetchingMore: false,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await loadProjects();
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadProjects(isRefresh: true);
    });
  }

  void clearSearchAndReload() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (state.searchQuery.isEmpty) {
      loadProjects(isRefresh: true);
    } else {
      state = state.copyWith(searchQuery: '');
      loadProjects(isRefresh: true);
    }
  }
}
