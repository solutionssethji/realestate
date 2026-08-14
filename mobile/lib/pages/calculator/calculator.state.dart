import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator.state.freezed.dart';

@freezed
sealed class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    @Default(3000000.0) double propertyPrice,
    @Default(600000.0) double downPayment,
    @Default(8.5) double interestRate,
    @Default(15) int tenureYears,
    @Default(0.0) double estimatedEMI,
    @Default(0.0) double totalInterest,
    @Default(0.0) double totalPayable,
  }) = _CalculatorState;
}
