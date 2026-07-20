import 'package:ichito/shared/providers/language_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<void> exportStatsToPDF({
    required String title,
    required Map<String, String> stats,
    required String fileNamePrefix,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Metric', 'Value'],
                data: stats.entries.map((e) => [e.key, e.value]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              ),
              pw.SizedBox(height: 40),
              pw.Text('Generated on ${DateFormat('.t(context)yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${output.path}/${fileNamePrefix}_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '$title PDF',
    );
  }

  static Future<void> exportStatsToCSV({
    required String title,
    required Map<String, String> stats,
    required String fileNamePrefix,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Metric,Value');
    for (final entry in stats.entries) {
      // Escape commas and quotes
      final key = '"${entry.key.replaceAll('"', '""')}"';
      final value = '"${entry.value.replaceAll('"', '""')}"';
      buffer.writeln('$key,$value');
    }

    final output = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${output.path}/${fileNamePrefix}_$dateStr.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '$title CSV',
    );
  }
}
