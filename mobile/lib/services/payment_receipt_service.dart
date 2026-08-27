import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';

class PaymentReceiptService {
  static Future<void> download(
    Map<String, dynamic> payment,
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();
    final amount = _number(payment['amount']);
    final currency = payment['currency']?.toString() ?? 'INR';
    final date = _formatDate(payment['createdAt']);
    final voucherNumber = payment['voucherNumber']?.toString() ?? 'N/A';
    final account = payment['description']?.toString().trim().isNotEmpty == true
        ? payment['description'].toString()
        : 'Plot Booking';
    final mode = payment['mode']?.toString() ?? 'N/A';
    final reference = payment['transactionId']?.toString() ?? 'N/A';
    final notes = payment['notes']?.toString() ?? '';
    final narration = payment['narration']?.toString() ?? notes;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              l10n.receiptTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              l10n.receiptVoucher,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 28),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.receiptNumber(voucherNumber)),
                pw.Text(l10n.receiptDate(date)),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Table(
              border: pw.TableBorder.all(width: 0.6),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1.3),
              },
              children: [
                _row(l10n.receiptParticulars, l10n.receiptAmount, bold: true),
                _row(l10n.receiptAccount(account), _money(currency, amount)),
                _row(
                  '${l10n.receiptPaymentMode(mode)}\n${l10n.receiptReference(reference)}${notes.isNotEmpty ? '\n${l10n.receiptNotes(notes)}' : ''}',
                  '',
                ),
                _row('Narration: ${narration.isEmpty ? ' ' : narration}', ''),
                _row(
                  l10n.receiptAmountInWords(_amountInWords(amount)),
                  _money(currency, amount),
                ),
                _row(l10n.receiptTotal, _money(currency, amount), bold: true),
              ],
            ),
            pw.Spacer(),
            pw.Text(
              l10n.computerGeneratedReceipt,
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'payment-receipt-$voucherNumber.pdf',
    );
  }

  static pw.TableRow _row(String left, String right, {bool bold = false}) {
    final style = pw.TextStyle(
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(left, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(right, style: style, textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  static double _number(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static String _money(String currency, double amount) =>
      '$currency ${NumberFormat('#,##0.00').format(amount)}';

  static String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? 'N/A'
        : DateFormat('dd-MM-yyyy hh:mm a').format(date.toLocal());
  }

  static String _amountInWords(double amount) {
    final rounded = amount.round();
    if (rounded == 0) return 'Zero only';
    final parts = <String>[];
    final crore = rounded ~/ 10000000;
    final lakh = (rounded % 10000000) ~/ 100000;
    final thousand = (rounded % 100000) ~/ 1000;
    final remainder = rounded % 1000;
    if (crore > 0) parts.add('${_underThousand(crore)} Crore');
    if (lakh > 0) parts.add('${_underThousand(lakh)} Lakh');
    if (thousand > 0) parts.add('${_underThousand(thousand)} Thousand');
    if (remainder > 0) parts.add(_underThousand(remainder));
    return '${parts.join(' ')} only';
  }

  static String _underThousand(int value) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    if (value < 20) {
      return ones[value];
    }
    if (value < 100) {
      return '${tens[value ~/ 10]}${value % 10 == 0 ? '' : ' ${ones[value % 10]}'}';
    }
    return '${ones[value ~/ 100]} Hundred${value % 100 == 0 ? '' : ' ${_underThousand(value % 100)}'}';
  }
}
