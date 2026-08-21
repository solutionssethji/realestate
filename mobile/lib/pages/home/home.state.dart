import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/project.dart';
import '../../../models/offer.dart';

part 'home.state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Project> projects,
    @Default([]) List<Offer> offers,
    String? contactPhone,
    String? contactWhatsapp,
  }) = _HomeState;
}
