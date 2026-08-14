import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/plot.dart';

part 'plot_details.state.freezed.dart';

@freezed
sealed class PlotDetailsState with _$PlotDetailsState {
  const factory PlotDetailsState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    Plot? plot,
  }) = _PlotDetailsState;
}
