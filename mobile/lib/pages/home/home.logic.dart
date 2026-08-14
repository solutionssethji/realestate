import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home.state.dart';
import '../../../services/api_service.dart';

part 'home.logic.g.dart';

@riverpod
class HomeLogic extends _$HomeLogic {
  @override
  HomeState build() {
    loadProjects();
    return const HomeState();
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final projects = await ApiService.getProjects();
      state = state.copyWith(isLoading: false, projects: projects);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
