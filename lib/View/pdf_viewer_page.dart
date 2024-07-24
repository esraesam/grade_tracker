import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String studentName;

  const PDFViewerPage(
      {Key? key, required this.pdfUrl, required this.studentName})
      : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(widget.pdfUrl));
    final bytes = response.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp.pdf');

    await file.writeAsBytes(bytes, flush: true);
    setState(() {
      localPath = file.path;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF: ${widget.studentName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
            ),
    );
  }
}
