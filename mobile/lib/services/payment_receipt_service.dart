import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'cms_service.dart';

class PaymentReceiptService {
  static Future<pw.Document> _generateReceiptPdf(
    Map<String, dynamic>? bookingData,
    Map<String, dynamic> payment,
  ) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/logo_with_text.png');
    final logoImage = pw.MemoryImage(
      logoData.buffer.asUint8List(
        logoData.offsetInBytes,
        logoData.lengthInBytes,
      ),
    );

    final transparentLogoData = await rootBundle.load(
      'assets/transparent_logo.png',
    );
    final transparentLogoImage = pw.MemoryImage(
      transparentLogoData.buffer.asUint8List(
        transparentLogoData.offsetInBytes,
        transparentLogoData.lengthInBytes,
      ),
    );

    final primary = PdfColor.fromHex('#8C1D2F');
    final textGrey = PdfColor.fromHex('#64748B');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final borderGrey = PdfColor.fromHex('#E2E8F0');

    final settings = await CmsService.getReceiptSettings();
    final companyName =
        settings['companyName'] ?? 'Shubhaytanam Buildtech Pvt Ltd';
    final address = settings['address'] ?? '';
    final stateName = settings['stateName'] ?? '';
    final stateCode = settings['stateCode'] ?? '';
    final gst = settings['gstNumber'] ?? '';
    final cin = settings['cin'] ?? '';
    final pan = settings['panNumber'] ?? '';
    final tan = settings['tanNumber'] ?? '';
    final email = settings['email'] ?? 'info@shubhaytanam.com';
    final authSignatory =
        settings['authorisedSignatory'] ?? 'Authorised Signatory';

    final amount = _number(payment['amount']);
    final voucherNumber = payment['voucherNumber']?.toString() ?? 'N/A';
    final customerName =
        bookingData?['firstApplicantName']?.toString() ?? 'N/A';
    final mobileNumber =
        bookingData?['firstApplicantMobile']?.toString() ?? 'N/A';
    final projectName = bookingData?['projectName']?.toString() ?? 'N/A';
    final plotNumber = bookingData?['plotNumber']?.toString() ?? 'N/A';
    final date = _formatDate(payment['createdAt']);
    final mode = payment['mode']?.toString() ?? 'CASH';
    final bank = payment['bankName']?.toString() ?? '';
    final txnId = payment['transactionId']?.toString() ?? '';
    final bankThrough = bank.isNotEmpty ? bank : 'N/A';
    final referenceTxnId = txnId.isNotEmpty ? txnId : 'N/A';
    final narration =
        payment['narration']?.toString() ??
        payment['notes']?.toString() ??
        'N/A';
    final amountInWords = _amountInWords(amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                left: 60,
                top: 250,
                right: 60,
                bottom: 250,
                child: pw.Opacity(
                  opacity: 0.05,
                  child: pw.Image(transparentLogoImage),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(height: 12, color: primary),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Image(logoImage, width: 140),
                                pw.SizedBox(height: 12),
                                pw.Text(
                                  companyName,
                                  style: pw.TextStyle(
                                    color: primary,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '$address\\n$stateName${stateCode.isNotEmpty ? ', $stateCode' : ''}',
                                  style: pw.TextStyle(
                                    color: textGrey,
                                    fontSize: 9,
                                  ),
                                ),
                                pw.Text(
                                  'GST: $gst | CIN: $cin',
                                  style: pw.TextStyle(
                                    color: textGrey,
                                    fontSize: 9,
                                  ),
                                ),
                                pw.Text(
                                  'PAN: $pan | TAN: $tan',
                                  style: pw.TextStyle(
                                    color: textGrey,
                                    fontSize: 9,
                                  ),
                                ),
                                pw.Text(
                                  'Email: $email',
                                  style: pw.TextStyle(
                                    color: textGrey,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                            pw.Text(
                              'VOUCHER: $voucherNumber',
                              style: pw.TextStyle(
                                color: PdfColors.blueGrey900,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 30),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            color: bgLight,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 6,
                                height: 70,
                                decoration: pw.BoxDecoration(
                                  color: primary,
                                  borderRadius: const pw.BorderRadius.only(
                                    topLeft: pw.Radius.circular(4),
                                    bottomLeft: pw.Radius.circular(4),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'AMOUNT RECEIVED',
                                      style: pw.TextStyle(
                                        color: textGrey,
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      'Rs. ${NumberFormat('#,##0.00').format(amount)}',
                                      style: pw.TextStyle(
                                        color: primary,
                                        fontSize: 22,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 30),
                        pw.Text(
                          'RECEIVED WITH THANKS FROM',
                          style: pw.TextStyle(
                            color: textGrey,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '+91 $mobileNumber',
                          style: pw.TextStyle(color: textGrey, fontSize: 10),
                        ),
                        pw.SizedBox(height: 30),
                        pw.Text(
                          'PAYMENT DETAILS',
                          style: pw.TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: borderGrey,
                              width: 0.5,
                            ),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                          child: pw.Column(
                            children: [
                              _detailRow('Date', date, borderGrey, bgLight),
                              _detailRow(
                                'Property / Account',
                                '$projectName - Plot $plotNumber',
                                borderGrey,
                                bgLight,
                              ),
                              _detailRow(
                                'Payment Mode',
                                mode,
                                borderGrey,
                                bgLight,
                              ),
                              _detailRow(
                                'Bank / Through',
                                bankThrough,
                                borderGrey,
                                bgLight,
                              ),
                              _detailRow(
                                'Reference / Txn ID',
                                referenceTxnId,
                                borderGrey,
                                bgLight,
                              ),
                              _detailRow(
                                'Amount in Words',
                                amountInWords,
                                borderGrey,
                                bgLight,
                              ),
                              _detailRow(
                                'Narration',
                                narration,
                                borderGrey,
                                bgLight,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 50),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  width: 150,
                                  height: 1,
                                  color: primary,
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  authSignatory,
                                  style: pw.TextStyle(
                                    color: textGrey,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _detailRow(
    String label,
    String value,
    PdfColor borderColor,
    PdfColor bgLight, {
    bool isLast = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: isLast
            ? null
            : pw.Border(bottom: pw.BorderSide(color: borderColor, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 140,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: pw.BoxDecoration(
              color: bgLight,
              border: pw.Border(
                right: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#64748B'),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> download(
    Map<String, dynamic>? bookingData,
    Map<String, dynamic> payment,
  ) async {
    final pdf = await _generateReceiptPdf(bookingData, payment);
    final voucherNumber = payment['voucherNumber']?.toString() ?? 'N/A';
    final safeVoucher = voucherNumber.replaceAll(
      RegExp(r'[^a-zA-Z0-9\-]'),
      '_',
    );
    final bytes = await pdf.save();

    try {
      await FilePicker.saveFile(
        dialogTitle: 'Save Receipt',
        fileName: 'payment-receipt-$safeVoucher.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );
    } catch (e) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'payment-receipt-$safeVoucher.pdf',
      );
    }
  }

  static Future<void> view(
    Map<String, dynamic>? bookingData,
    Map<String, dynamic> payment,
  ) async {
    final pdf = await _generateReceiptPdf(bookingData, payment);
    final voucherNumber = payment['voucherNumber']?.toString() ?? 'N/A';
    final safeVoucher = voucherNumber.replaceAll(
      RegExp(r'[^a-zA-Z0-9\-]'),
      '_',
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'payment-receipt-$safeVoucher.pdf',
    );
  }

  static Future<pw.Document> _generateLedgerPdf(
    Map<String, dynamic>? bookingData,
    List<dynamic> payments,
  ) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/logo_with_text.png');
    final logoImage = pw.MemoryImage(
      logoData.buffer.asUint8List(
        logoData.offsetInBytes,
        logoData.lengthInBytes,
      ),
    );

    final transparentLogoData = await rootBundle.load(
      'assets/transparent_logo.png',
    );
    final transparentLogoImage = pw.MemoryImage(
      transparentLogoData.buffer.asUint8List(
        transparentLogoData.offsetInBytes,
        transparentLogoData.lengthInBytes,
      ),
    );

    final settings = await CmsService.getReceiptSettings();
    final companyName =
        settings['companyName'] ?? 'Shubhaytanam Buildtech Pvt Ltd';
    final address = settings['address'] ?? 'Bypass Road, Sipahi Tola, Purnia';
    final stateName = settings['stateName'] ?? 'Bihar';
    final stateCode = settings['stateCode'] ?? '10';
    final gst = settings['gstNumber'] ?? '10ABOCS8829D1Z8';
    final cin = settings['cin'] ?? 'U68100BR2024PTC072749';
    final pan = settings['panNumber'] ?? 'ABOCS8829D';
    final tan = settings['tanNumber'] ?? 'PTNS18925E';
    final email = settings['email'] ?? 'info@shubhaytanam.com';
    final authSignatory =
        settings['authorisedSignatory'] ?? 'Authorised Signatory';

    final primary = PdfColor.fromHex('#8C1D2F');
    final textGrey = PdfColor.fromHex('#64748B');
    final textDark = PdfColor.fromHex('#1E293B');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final bgHeader = PdfColor.fromHex('#F1F5F9');
    final borderGrey = PdfColor.fromHex('#E2E8F0');
    final successColor = PdfColor.fromHex('#16A34A');
    final dangerColor = PdfColor.fromHex('#DC2626');

    final customerName =
        bookingData?['firstApplicantName']?.toString() ?? 'N/A';
    final mobileNumber =
        bookingData?['firstApplicantMobile']?.toString() ?? 'N/A';
    final projectName = bookingData?['projectName']?.toString() ?? 'N/A';
    final plotNumber = bookingData?['plotNumber']?.toString() ?? 'N/A';
    final generatedDate = DateFormat('d/M/yyyy').format(DateTime.now());

    final totalPlotValue = _number(bookingData?['totalAmount']);
    double totalPaid = 0;
    for (var p in payments) {
      totalPaid += _number(p['amount']);
    }
    final balance = totalPlotValue - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: pw.Container(height: 12, color: primary),
                  ),
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.05,
                      child: pw.Image(transparentLogoImage),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(logoImage, width: 140),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      companyName,
                      style: pw.TextStyle(
                        color: primary,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '$address\n$stateName${stateCode.isNotEmpty ? ', $stateCode' : ''}',
                      style: pw.TextStyle(color: textGrey, fontSize: 9),
                    ),
                    pw.Text(
                      'GST: $gst | CIN: $cin',
                      style: pw.TextStyle(color: textGrey, fontSize: 9),
                    ),
                    pw.Text(
                      'PAN: $pan | TAN: $tan',
                      style: pw.TextStyle(color: textGrey, fontSize: 9),
                    ),
                    pw.Text(
                      'Email: $email',
                      style: pw.TextStyle(color: textGrey, fontSize: 9),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'STATEMENT OF ACCOUNT',
                      style: pw.TextStyle(
                        color: textDark,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated: $generatedDate',
                      style: pw.TextStyle(color: textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              decoration: pw.BoxDecoration(
                color: bgLight,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 6,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      color: primary,
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(4),
                        bottomLeft: pw.Radius.circular(4),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryCol(
                            'TOTAL AMOUNT',
                            totalPlotValue,
                            PdfColors.black,
                          ),
                          _summaryCol('PAID AMOUNT', totalPaid, successColor),
                          _summaryCol('PENDING BALANCE', balance, dangerColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'CUSTOMER DETAILS',
              style: pw.TextStyle(
                color: textGrey,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              customerName,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '+91 $mobileNumber',
              style: pw.TextStyle(color: textGrey, fontSize: 10),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Project: $projectName - Plot $plotNumber',
              style: pw.TextStyle(color: textGrey, fontSize: 10),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'TRANSACTION HISTORY',
              style: pw.TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(color: borderGrey, width: 0.5),
                top: pw.BorderSide(color: borderGrey, width: 0.5),
                horizontalInside: pw.BorderSide(color: borderGrey, width: 0.5),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.2),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.2),
                3: pw.FlexColumnWidth(2.5),
                4: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: bgHeader),
                  children: [
                    _headerCell('DATE'),
                    _headerCell('VOUCHER'),
                    _headerCell('MODE'),
                    _headerCell('BANK & TXN ID'),
                    _headerCell('AMOUNT (Rs)', alignRight: true),
                  ],
                ),
                ...payments.map((p) {
                  final date = _formatDate(p['createdAt'], short: true);
                  final voucher = p['voucherNumber']?.toString() ?? 'N/A';
                  final mode = p['mode']?.toString() ?? 'N/A';
                  final bank = p['bankName']?.toString() ?? '';
                  final txnId = p['transactionId']?.toString() ?? '';
                  final amount = _number(p['amount']);

                  final bankAndTxn = [
                    bank,
                    txnId,
                  ].where((e) => e.isNotEmpty).join(' - ');

                  return pw.TableRow(
                    children: [
                      _cell(date),
                      _cell(voucher),
                      _cell(mode),
                      _cell(bankAndTxn.isEmpty ? '-' : bankAndTxn),
                      _cell(_money('', amount).trim(), alignRight: true),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(width: 150, height: 1, color: primary),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      authSignatory,
                      style: pw.TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _summaryCol(String label, double amount, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#64748B'),
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Rs. ${NumberFormat('#,##0').format(amount)}',
          style: pw.TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _headerCell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#64748B'),
        ),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _cell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static Future<void> downloadAll(
    Map<String, dynamic>? bookingData,
    List<dynamic> payments,
  ) async {
    final pdf = await _generateLedgerPdf(bookingData, payments);
    final bytes = await pdf.save();

    try {
      await FilePicker.saveFile(
        dialogTitle: 'Save Ledger',
        fileName: 'payments-ledger.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );
    } catch (e) {
      await Printing.sharePdf(bytes: bytes, filename: 'payments-ledger.pdf');
    }
  }

  static Future<void> viewAll(
    Map<String, dynamic>? bookingData,
    List<dynamic> payments,
  ) async {
    final pdf = await _generateLedgerPdf(bookingData, payments);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'payments-ledger.pdf',
    );
  }

  static double _number(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static String _money(String currency, double amount) =>
      '$currency ${NumberFormat('#,##0.00').format(amount)}';

  static String _formatDate(dynamic value, {bool short = false}) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? 'N/A'
        : DateFormat(
            short ? 'd/M/yyyy' : 'dd-MM-yyyy hh:mm a',
          ).format(date.toLocal());
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
