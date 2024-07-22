// viewmodels/pdf_uploader_viewmodel.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grade_tracker/Model/pdf_file.dart';
import 'package:http/http.dart' as http;

class PDFUploaderViewModel extends ChangeNotifier {
  bool _isUploading = false;
  List<PDFFile> _indexedFiles = [];

  bool get isUploading => _isUploading;
  List<PDFFile> get indexedFiles => _indexedFiles;

  void setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  Future<void> fetchIndexedFiles() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/get_indexed_files.php'));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('files')) {
          final filesList = decodedResponse['files'] as List;
          _indexedFiles =
              filesList.map((file) => PDFFile.fromJson(file)).toList();
          notifyListeners();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to load indexed files. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching indexed files: $e');
    }
  }

  Future<void> uploadAndIndexPDF(BuildContext context) async {
    setUploading(true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          String fileName = file.name;
          Reference fileRef = FirebaseStorage.instance.ref('pdfs/$fileName');
          String downloadURL;

          try {
            await fileRef.putFile(File(file.path!));
            downloadURL = await fileRef.getDownloadURL();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF uploaded successfully. Indexing...')),
            );
          } catch (e) {
            print('Error uploading file: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading file: ${e.toString()}')),
            );
            return;
          }

          try {
            final response = await http.post(
              Uri.parse('http://10.0.2.2:8000/process_pdf.php'),
              body: {'pdfUrl': downloadURL, 'fileName': fileName},
            );

            if (response.statusCode == 200) {
              Map<String, dynamic> result = json.decode(response.body);

              if (result['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF indexed successfully')),
                );
              } else if (result['status'] == 'already_indexed') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('This PDF was already indexed')),
                );
              } else if (result['status'] == 'error') {
                throw Exception(result['message']);
              } else {
                throw Exception('Unexpected server response');
              }
              await fetchIndexedFiles();
            } else {
              throw Exception(
                  'Server responded with status code: ${response.statusCode}');
            }
          } catch (e) {
            print('Error during indexing: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error during indexing: ${e.toString()}')),
            );
          }
        }
      }
    } catch (e) {
      print('Unexpected error in uploadAndIndexPDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      setUploading(false);
    }
  }
}
