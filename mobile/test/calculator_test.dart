import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/services/calculator_service.dart';

void main() {
  group('CalculatorService Tests', () {
    test('Calculates EMI correctly for standard input', () {
      // 2400000 loan, 8.5% interest, 15 years
      final emi = CalculatorService.calculateEMI(
        principal: 2400000,
        annualInterestRate: 8.5,
        tenureInYears: 15,
      );

      // Expected EMI is approx 23633
      expect(emi.round(), 23634);
    });

    test('Returns 0 for invalid inputs', () {
      expect(
        CalculatorService.calculateEMI(
          principal: 0,
          annualInterestRate: 8.5,
          tenureInYears: 15,
        ),
        0.0,
      );
      expect(
        CalculatorService.calculateEMI(
          principal: 2400000,
          annualInterestRate: 0,
          tenureInYears: 15,
        ),
        0.0,
      );
      expect(
        CalculatorService.calculateEMI(
          principal: 2400000,
          annualInterestRate: 8.5,
          tenureInYears: 0,
        ),
        0.0,
      );
    });
  });
}
