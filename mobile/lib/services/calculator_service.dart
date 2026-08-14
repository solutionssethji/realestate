import 'dart:math';

class CalculatorService {
  static double calculateEMI({
    required double principal,
    required double annualInterestRate,
    required int tenureInYears,
  }) {
    if (principal <= 0 || annualInterestRate <= 0 || tenureInYears <= 0) {
      return 0.0;
    }

    final double monthlyRate = annualInterestRate / (12 * 100);
    final int tenureInMonths = tenureInYears * 12;

    final double emi =
        (principal * monthlyRate * pow(1 + monthlyRate, tenureInMonths)) /
        (pow(1 + monthlyRate, tenureInMonths) - 1);

    return emi;
  }
}
