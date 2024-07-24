import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  void addIndexedFile(PDFFile file) {
    _indexedFiles.add(file);
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
      print("Starting file picker");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        print("File selected: ${file.name}");

        if (file.path != null) {
          String fileName = file.name;
          Reference fileRef = FirebaseStorage.instance.ref('pdfs/$fileName');
          String downloadURL;

          try {
            print("Uploading file to Firebase Storage");
            await fileRef.putFile(File(file.path!));
            downloadURL = await fileRef.getDownloadURL();
            print('File uploaded to Firebase. Download URL: $downloadURL');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF uploaded successfully. Indexing...')),
            );
          } catch (e) {
            print('Error uploading file to Firebase: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading file: ${e.toString()}')),
            );
            return;
          }

          try {
            print('Sending request to index PDF...');
            final response = await http.post(
              Uri.parse('http://10.0.2.2:8000/process_pdf.php'),
              body: {'pdfUrl': downloadURL, 'fileName': fileName},
            );

            print(
                'Received response from server. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (response.statusCode == 200) {
              Map<String, dynamic> result = json.decode(response.body);

              if (result['status'] == 'success') {
                print('PDF indexed successfully');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF indexed successfully')),
                );

                // Add the new file to the list
                addIndexedFile(PDFFile(
                  fileName: fileName,
                  uploadDate: DateTime.now().toIso8601String(),
                ));
              } else {
                throw Exception(result['message'] ?? 'Unknown error occurred');
              }
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
      } else {
        print("No file selected");
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
