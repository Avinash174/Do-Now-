import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../model/task_model.dart';

class ExportService {
  static Future<void> exportToCSV(List<TaskModel> tasks) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "ID",
      "Title",
      "Description",
      "Category",
      "Status",
      "Scheduled Time",
      "Created At"
    ]);

    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description,
        task.category,
        task.isCompleted ? "Completed" : "Pending",
        DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(task.scheduleTime)),
        DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(task.createdAt)),
      ]);
    }

    String csvString = const csv.ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);

    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(path)], text: 'Exported Tasks CSV');
  }

  static Future<void> exportToPDF(List<TaskModel> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Do Now - Tasks Export",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ["Title", "Category", "Status", "Scheduled"],
            data: tasks.map((task) {
              return [
                task.title,
                task.category,
                task.isCompleted ? "Done" : "Pending",
                DateFormat('MMM dd, HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(task.scheduleTime)),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(path);

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'Exported Tasks PDF');
  }
}
