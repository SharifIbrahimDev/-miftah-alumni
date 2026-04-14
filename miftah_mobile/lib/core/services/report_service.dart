import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/contribution.dart';

class ReportService {
  static Future<void> generateFinancialReport({
    required String chapterName,
    required List<MonthlyContribution> contributions,
    required double totalIncome,
    required double totalExpense,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MIFTAH ALUMNI HUB', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('FINANCIAL STATEMENT', style: pw.TextStyle(color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Chapter: $chapterName'),
            pw.Text('Date: ${DateTime.now().toIso8601String().split('T')[0]}'),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 32),
            pw.Text('EXECUTIVE SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Gross Inflow:'),
                pw.Text('N${totalIncome.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Gross Outflow:'),
                pw.Text('N${totalExpense.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.red900)),
              ],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Current Liquid Balance:', style: pw.TextStyle(fontSize: 12)),
                pw.Text('N${(totalIncome - totalExpense).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.green900)),
              ],
            ),
            pw.SizedBox(height: 48),
            pw.Text('TRANSACTION LEDGER', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['Member', 'Reference', 'Amount', 'Status'],
              data: contributions.map((c) => [
                c.userName,
                c.month,
                'N${c.amount.toStringAsFixed(0)}',
                c.status.toUpperCase(),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF065F46)),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 60),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSignatureLine('President'),
                _buildSignatureLine('Cashier'),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildSignatureLine(String role) {
    return pw.Column(
      children: [
        pw.Container(width: 120, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
        pw.SizedBox(height: 4),
        pw.Text(role, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }
}
