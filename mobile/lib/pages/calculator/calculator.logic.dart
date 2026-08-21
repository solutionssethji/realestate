import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'calculator.state.dart';
import '../../services/calculator_service.dart';

part 'calculator.logic.g.dart';

@riverpod
class CalculatorLogic extends _$CalculatorLogic {
  @override
  CalculatorState build() {
    Future.microtask(_calculate);
    return const CalculatorState();
  }

  void updatePropertyPrice(double price) {
    if (price < 0) return;

    // Auto-adjust down payment if it exceeds new property price
    var newDownPayment = state.downPayment;
    if (newDownPayment >= price) {
      newDownPayment = price * 0.2; // default to 20%
    }

    state = state.copyWith(propertyPrice: price, downPayment: newDownPayment);
    _calculate();
  }

  void updateDownPayment(double payment) {
    if (payment < 0 || payment > state.propertyPrice) return;
    state = state.copyWith(downPayment: payment);
    _calculate();
  }

  void updateInterestRate(double rate) {
    if (rate <= 0 || rate > 30) return;
    state = state.copyWith(interestRate: rate);
    _calculate();
  }

  void updateTenure(int years) {
    if (years <= 0 || years > 30) return;
    state = state.copyWith(tenureYears: years);
    _calculate();
  }

  void _calculate() {
    final loanAmount = state.propertyPrice - state.downPayment;

    final emi = CalculatorService.calculateEMI(
      principal: loanAmount,
      annualInterestRate: state.interestRate,
      tenureInYears: state.tenureYears,
    );

    final totalPayable = emi * (state.tenureYears * 12);
    final totalInterest = totalPayable - loanAmount;

    state = state.copyWith(
      estimatedEMI: emi.isNaN ? 0.0 : emi,
      totalPayable: totalPayable.isNaN ? 0.0 : totalPayable,
      totalInterest: totalInterest.isNaN ? 0.0 : totalInterest,
    );
  }
}
