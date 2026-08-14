import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/project.dart';

part 'project_details.state.freezed.dart';

@freezed
sealed class ProjectDetailsState with _$ProjectDetailsState {
  const factory ProjectDetailsState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    Project? project,
  }) = _ProjectDetailsState;
}
