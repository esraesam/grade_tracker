import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:grade_tracker/Model/pdfFile.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFViewerPage extends StatelessWidget {
  final PDFFile pdfFile;

  const PDFViewerPage({required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfFile.name),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: getPdfFile(pdfFile.url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('PDF file not found.');
            } else {
              String path = snapshot.data!;
              return PDFView(filePath: path);
            }
          },
        ),
      ),
    );
  }

  Future<String> getPdfFile(String pdfUrl) async {
    String fileName = pdfUrl.split('/').last; // Extract file name from URL
    String filePath = await _localPath + '/' + fileName;

    // Check if file already exists locally
    bool fileExists = await File(filePath).exists();
    if (!fileExists) {
      // Download the file if not exists locally
      try {
        await File(filePath).writeAsBytes(await _getPdfBytes(pdfUrl));
      } catch (e) {
        print('Error downloading PDF: $e');
        return '';
      }
    }
    return filePath;
  }

  Future<List<int>> _getPdfBytes(String pdfUrl) async {
    HttpClient client = HttpClient();
    final request = await client.getUrl(Uri.parse(pdfUrl));
    final response = await request.close();
    if (response.statusCode == 200) {
      return await consolidateHttpClientResponseBytes(response);
    } else {
      throw Exception('Failed to load PDF');
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
