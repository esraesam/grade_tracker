import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class UploadPdfViewModel extends ChangeNotifier {
  File? _pdf;
  String? _uploadingMessage;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  String? fileName;

  File? get selectedPdf => _pdf;
  double get uploadProgress => _uploadProgress;
  String? get uploadingMessage => _uploadingMessage;

  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _pdf = File(result.files.single.path!);
      notifyListeners();
    }
  }

  Future<void> uploadPdf() async {
    if (_pdf == null) {
      _showToast('Please select a PDF file.');
      return;
    }

    try {
      fileName = _ensureValidFileName(path.basename(_pdf!.path));
      String encodedFileName = Uri.encodeComponent(fileName!);
      Reference storageRef =
          FirebaseStorage.instance.ref().child('pdfs/$encodedFileName');

      _uploadTask = storageRef.putFile(_pdf!);

      _uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        _uploadingMessage =
            'Uploading... ${(_uploadProgress * 100).toStringAsFixed(2)}%';
        notifyListeners();
      }, onError: (error) {
        _showToast('File Upload Error: $error');
      });

      await _uploadTask!.whenComplete(() async {
        _uploadingMessage = 'Upload Complete!';
        _uploadProgress = 1.0;
        _showToast('Upload Complete!');

        final pdfUrl = await storageRef.getDownloadURL();
        print('Original URL: $pdfUrl');

        final encodedPdfUrl = Uri.encodeComponent(pdfUrl);
        print('Encoded URL: $encodedPdfUrl');

        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/index.php'),
          body: {'pdfUrl': encodedPdfUrl},
        );

        print('PHP Response: ${response.body}');

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success']) {
            _showToast('Indexed successfully');
          } else {
            _showToast('Indexing failed: ${result['message']}');
          }
        } else {
          _showToast(
              'Failed to index PDF. Status code: ${response.statusCode}');
        }

        Future.delayed(const Duration(seconds: 1), () {
          _pdf = null;
          _uploadProgress = 0.0;
          _uploadingMessage = null;
          _uploadTask = null;
          notifyListeners();
        });
      });
    } catch (e) {
      print('Error in uploadPdf: $e');
      _showToast('File Upload Error: $e');
    }
  }

  String _ensureValidFileName(String fileName) {
    const maxLength = 20;
    if (fileName.length > maxLength) {
      String fileExt = path.extension(fileName);
      fileName = fileName.substring(0, maxLength - fileExt.length) + fileExt;
    }
    return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
  }

  void cancelUpload() {
    _uploadTask?.cancel();
    _uploadProgress = 0.0;
    _uploadingMessage = 'Upload Cancelled';
    _pdf = null;
    _uploadTask = null;
    notifyListeners();
    _showToast('Upload Cancelled');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
