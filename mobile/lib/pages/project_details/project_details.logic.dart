import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'project_details.state.dart';
import '../../../services/api_service.dart';

part 'project_details.logic.g.dart';

@riverpod
class ProjectDetailsLogic extends _$ProjectDetailsLogic {
  @override
  ProjectDetailsState build(String projectId) {
    Future.microtask(() => loadProject(projectId));
    return const ProjectDetailsState();
  }

  Future<void> loadProject(String projectId) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final project = await ApiService.getProject(projectId);
      if (project == null) {
        throw Exception('Project not found');
      }
      state = state.copyWith(isLoading: false, project: project);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
