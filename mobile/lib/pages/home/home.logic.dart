import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home.state.dart';
import '../../../services/api_service.dart';
import '../../../models/project.dart';
import '../../../models/offer.dart';
part 'home.logic.g.dart';

@Riverpod(keepAlive: true)
class HomeLogic extends _$HomeLogic {
  @override
  HomeState build() {
    return const HomeState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final results = await Future.wait([
        ApiService.getProjects(limit: 10, isFeatured: true),
        ApiService.getOffers(limit: 7),
        ApiService.getContactSettings(),
      ]);

      final projectsTuple = results[0] as (List<Project>, dynamic);
      final offersTuple = results[1] as (List<Offer>, dynamic);
      final contactSettings = results[2] as Map<String, String>;

      state = state.copyWith(
        isLoading: false,
        projects: projectsTuple.$1,
        offers: offersTuple.$1,
        contactPhone: contactSettings['phone']?.isNotEmpty == true
            ? contactSettings['phone']
            : null,
        contactWhatsapp: contactSettings['whatsapp']?.isNotEmpty == true
            ? contactSettings['whatsapp']
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
