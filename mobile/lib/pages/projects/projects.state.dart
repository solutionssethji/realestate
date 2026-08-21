import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/project.dart';

part 'projects.state.freezed.dart';

@freezed
sealed class ProjectsState with _$ProjectsState {
  const factory ProjectsState({
    @Default(true) bool isLoading,
    @Default(false) bool isFetchingMore,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Project> allProjects,
    @Default([]) List<Project> filteredProjects,
    @Default('') String searchQuery,
    @Default(true) bool hasMore,
    dynamic lastDocument,
  }) = _ProjectsState;
}
