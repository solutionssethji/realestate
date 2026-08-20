import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;
import '../../widgets/premium_app_bar.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';


class EmiCalculatorPage extends HookConsumerWidget {
  const EmiCalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final principalController = useTextEditingController();
    final downPaymentController = useTextEditingController();
    final rateController = useTextEditingController(text: '9');
    final tenureController = useTextEditingController(text: '10');

    final emiResult = useState<double>(0);
    final totalPayment = useState<double>(0);
    final totalInterest = useState<double>(0);

    void calculateEmi() {
      final pStr = principalController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      final dStr = downPaymentController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      final rStr = rateController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      final tStr = tenureController.text.replaceAll(RegExp(r'[^0-9.]'), '');

      double principal = double.tryParse(pStr) ?? 0;
      double downPayment = double.tryParse(dStr) ?? 0;
      double ratePerYear = double.tryParse(rStr) ?? 9;
      double years = double.tryParse(tStr) ?? 10;

      double loanAmount = principal - downPayment;
      if (loanAmount <= 0 || ratePerYear <= 0 || years <= 0) {
        emiResult.value = 0;
        totalPayment.value = 0;
        totalInterest.value = 0;
        return;
      }

      double r = (ratePerYear / 12) / 100;
      double n = years * 12;

      double emi = (loanAmount * r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
      
      emiResult.value = emi;
      totalPayment.value = emi * n;
      totalInterest.value = (emi * n) - loanAmount;
    }

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.emiCalculator),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.midnightNavy, AppTheme.slateBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.approximateEmi,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  AppSpacing.hSm,
                  Text(
                    '₹${emiResult.value.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    '/ month',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hXl,
            
            _buildInputField(context, controller: principalController, label: context.l10n.plotPrice, prefix: '₹', onChanged: (_) => calculateEmi()),
            AppSpacing.hLg,
            _buildInputField(context, controller: downPaymentController, label: context.l10n.downPayment, prefix: '₹', onChanged: (_) => calculateEmi()),
            AppSpacing.hLg,
            Row(
              children: [
                Expanded(child: _buildInputField(context, controller: rateController, label: context.l10n.interestRate, prefix: '%', onChanged: (_) => calculateEmi())),
                AppSpacing.wLg,
                Expanded(child: _buildInputField(context, controller: tenureController, label: context.l10n.loanTenure, prefix: 'Yrs', onChanged: (_) => calculateEmi())),
              ],
            ),
            AppSpacing.hXl,
            if (emiResult.value > 0) ...[
              const Divider(),
              AppSpacing.hLg,
              _buildSummaryRow(context, context.l10n.principalAmount, '₹${(double.tryParse(principalController.text) ?? 0 - (double.tryParse(downPaymentController.text) ?? 0)).toStringAsFixed(0)}'),
              AppSpacing.hSm,
              _buildSummaryRow(context, context.l10n.totalInterest, '₹${totalInterest.value.toStringAsFixed(0)}'),
              AppSpacing.hSm,
              _buildSummaryRow(context, context.l10n.totalPayment, '₹${totalPayment.value.toStringAsFixed(0)}', isBold: true),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, {required TextEditingController controller, required String label, required String prefix, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        AppSpacing.hSm,
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixText: '$prefix ',
            prefixStyle: const TextStyle(color: AppTheme.midnightNavy, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: AppTheme.midnightNavy.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.midnightNavy, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppTheme.midnightNavy : AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.midnightNavy : AppTheme.midnightNavy,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
