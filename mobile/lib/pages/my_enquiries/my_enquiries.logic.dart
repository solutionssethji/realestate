import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import 'my_enquiries.state.dart';

part 'my_enquiries.logic.g.dart';

@riverpod
class MyEnquiriesLogic extends _$MyEnquiriesLogic {
  @override
  MyEnquiriesState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => loadEnquiries(isRefresh: true));
    } else {
      return const MyEnquiriesState(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
    }
    return const MyEnquiriesState();
  }

  Future<void> loadEnquiries({bool isRefresh = false}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        enquiries: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.enquiries.isNotEmpty) {
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
      final (newEnquiries, newLastDoc) = await ApiService.getUserEnquiries(
        user.uid,
        lastDoc: state.lastDocument,
        limit: 10,
      );

      // Fetch project and plot names
      final projectIds = newEnquiries.map((e) => e['projectId'] as String?).where((id) => id != null).toSet();
      final plotIds = newEnquiries.map((e) => e['plotId'] as String?).where((id) => id != null).toSet();

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

      final enrichedEnquiries = newEnquiries.map((e) {
        final projectId = e['projectId'] as String?;
        final plotId = e['plotId'] as String?;
        return {
          ...e,
          if (projectId != null && projectNames.containsKey(projectId)) 'projectName': projectNames[projectId],
          if (plotId != null && plotNames.containsKey(plotId)) 'plotName': plotNames[plotId],
        };
      }).toList();

      state = state.copyWith(
        enquiries: isRefresh ? enrichedEnquiries : [...state.enquiries, ...enrichedEnquiries],
        lastDocument: newLastDoc,
        hasMore: newEnquiries.length == 10,
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
    await loadEnquiries();
  }
}
