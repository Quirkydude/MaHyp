import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../features/bp_monitoring/data/models/bp_reading_model.dart';
import '../../features/medication/data/models/medication_model.dart';

/// Service for generating health reports and exporting data
class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final _dateFormat = DateFormat('MMM dd, yyyy');
  final _timeFormat = DateFormat('HH:mm');

  /// Generate and share BP readings PDF report
  Future<void> generateBPReport(List<BPReadingModel> readings, {String? userName}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Blood Pressure Report', userName),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildBPSummary(readings),
          pw.SizedBox(height: 20),
          _buildBPTable(readings),
        ],
      ),
    );

    await _saveAndSharePdf(pdf, 'bp_report');
  }

  /// Generate and share medication adherence PDF report  
  Future<void> generateMedicationReport(
    List<MedicationModel> medications, 
    Map<String, int> adherenceStats,
    {String? userName}
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Medication Report', userName),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildMedicationSummary(adherenceStats),
          pw.SizedBox(height: 20),
          _buildMedicationList(medications),
        ],
      ),
    );

    await _saveAndSharePdf(pdf, 'medication_report');
  }

  /// Export BP readings as CSV
  Future<void> exportBPAsCSV(List<BPReadingModel> readings) async {
    final buffer = StringBuffer();
    
    // Header row
    buffer.writeln('Date,Time,Systolic,Diastolic,Heart Rate,Category,Notes');
    
    // Data rows
    for (final reading in readings) {
      buffer.writeln(
        '${_dateFormat.format(reading.recordedAt)},'
        '${_timeFormat.format(reading.recordedAt)},'
        '${reading.systolic},'
        '${reading.diastolic},'
        '${reading.heartRate},'
        '${reading.categoryName},'
        '"${reading.notes ?? ""}"'
      );
    }

    await _saveAndShareCSV(buffer.toString(), 'bp_readings');
  }

  /// Export medications as CSV
  Future<void> exportMedicationsAsCSV(List<MedicationModel> medications) async {
    final buffer = StringBuffer();
    
    // Header row
    buffer.writeln('Name,Dosage,Frequency,Times,Reminder,Notes,Created');
    
    // Data rows
    for (final med in medications) {
      buffer.writeln(
        '${med.name},'
        '${med.dosage},'
        '${med.frequencyString},'
        '"${med.timesOfDay.map((t) => t.name).join(", ")}",'
        '${med.reminderEnabled ? "Yes" : "No"},'
        '"${med.notes ?? ""}",'
        '${_dateFormat.format(med.createdAt)}'
      );
    }

    await _saveAndShareCSV(buffer.toString(), 'medications');
  }

  // Private helper methods

  pw.Widget _buildHeader(String title, String? userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MaHyp Health Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        if (userName != null) ...[
          pw.SizedBox(height: 4),
          pw.Text('Patient: $userName', style: const pw.TextStyle(fontSize: 12)),
        ],
        pw.Text(
          'Generated: ${_dateFormat.format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildBPSummary(List<BPReadingModel> readings) {
    if (readings.isEmpty) {
      return pw.Text('No readings available');
    }

    final stats = BPStatistics.fromReadings(readings);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Summary (Last ${readings.length} readings)', 
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Average', '${stats.avgSystolic}/${stats.avgDiastolic}', 'mmHg'),
              _buildStatBox('Highest', '${stats.highestReading?.systolic ?? 0}/${stats.highestReading?.diastolic ?? 0}', 'mmHg'),
              _buildStatBox('Lowest', '${stats.lowestReading?.systolic ?? 0}/${stats.lowestReading?.diastolic ?? 0}', 'mmHg'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatBox(String label, String value, String unit) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(unit, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
      ],
    );
  }

  pw.Widget _buildBPTable(List<BPReadingModel> readings) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: ['Date', 'BP (mmHg)', 'Pulse', 'Category'].map((text) => 
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
          ).toList(),
        ),
        // Data rows
        ...readings.take(50).map((reading) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${_dateFormat.format(reading.recordedAt)}\n${_timeFormat.format(reading.recordedAt)}', 
                style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${reading.systolic}/${reading.diastolic}', style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${reading.heartRate} bpm', style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(reading.categoryName, style: const pw.TextStyle(fontSize: 8)),
            ),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildMedicationSummary(Map<String, int> stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Adherence Summary (Last 7 days)', 
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Adherence', '${stats['adherence'] ?? 0}%', ''),
              _buildStatBox('Taken', '${stats['taken'] ?? 0}', 'doses'),
              _buildStatBox('Missed', '${stats['missed'] ?? 0}', 'doses'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationList(List<MedicationModel> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Medications', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 10),
        ...medications.map((med) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(med.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${med.dosage} • ${med.frequencyString}', 
                style: const pw.TextStyle(fontSize: 10)),
              if (med.notes != null)
                pw.Text('Notes: ${med.notes}', 
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _saveAndSharePdf(pw.Document pdf, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${filename}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'MaHyp Health Report',
      );
    } catch (e) {
      debugPrint('Error saving/sharing PDF');
      rethrow;
    }
  }

  Future<void> _saveAndShareCSV(String content, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${filename}_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'MaHyp Health Data Export',
      );
    } catch (e) {
      debugPrint('Error saving/sharing CSV');
      rethrow;
    }
  }
}
