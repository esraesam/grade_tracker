import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grade_tracker/Utils/constants.dart';
import 'package:grade_tracker/studentSearchPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PDFUploaderPage extends StatefulWidget {
  @override
  _PDFUploaderPageState createState() => _PDFUploaderPageState();
}

class _PDFUploaderPageState extends State<PDFUploaderPage> {
  bool _isUploading = false;
  List<Map<String, dynamic>> _indexedFiles = [];

  String decodeFileName(String fileName) {
    try {
      return utf8.decode(fileName.codeUnits);
    } catch (e) {
      print('Error decoding file name: $e');
      return fileName; // Return the original string if decoding fails
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchIndexedFiles();
  }

  Future<void> _uploadAndIndexPDF() async {
    setState(() {
      _isUploading = true;
    });

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
            // Upload file to Firebase Storage
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

          // Index PDF
          try {
            final response = await http.post(
              Uri.parse('http://10.0.2.2:8000/process_pdf.php'),
              body: {'pdfUrl': downloadURL, 'fileName': fileName},
            );

            print('Raw server response: ${response.body}'); // Log raw response

            if (response.statusCode == 200) {
              Map<String, dynamic> result = json.decode(response.body);

              print('Parsed server response: $result'); // Log parsed response

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
              // Refresh the list of indexed files
              await _fetchIndexedFiles();
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
      print('Unexpected error in _uploadAndIndexPDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchIndexedFiles() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/get_indexed_files.php'));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('files')) {
          final filesList = decodedResponse['files'] as List;
          if (mounted) {
            // Check if the widget is still in the tree
            setState(() {
              _indexedFiles = List<Map<String, dynamic>>.from(filesList);
            });
          }
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to load indexed files. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching indexed files: $e');
      if (mounted) {
        // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching indexed files: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => StudentSearchPage()));
        },
        child: Container(
          height: height * 0.06,
          width: width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: primaryColor,
          ),
          child: const Center(
            child: Text(
              'Search Pdfs',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Pdf Uploader',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/images/upload.png',
            height: height * 0.1,
          ),
          SizedBox(height: height * 0.02),
          Container(
            height: height * 0.051,
            width: width * 0.7,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: const Offset(3, 4),
                  blurRadius: 6,
                  spreadRadius: 6,
                  color: Colors.grey.withOpacity(0.10),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: _isUploading ? null : _uploadAndIndexPDF,
              child: Text(_isUploading ? 'Uploading...' : 'Upload PDF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  )),
            ),
          ),
          // ElevatedButton(
          //   onPressed: _isUploading ? null : _uploadAndIndexPDF,
          //   child: Text(_isUploading ? 'Uploading...' : 'Upload PDF'),
          // ),
          SizedBox(height: height * 0.02),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03),
              child: ListView.builder(
                itemCount: _indexedFiles.length,
                itemBuilder: (context, index) {
                  final fileName =
                      _indexedFiles[index]['file_name'] ?? 'Unnamed File';
                  final uploadDate =
                      _indexedFiles[index]['upload_date'] ?? 'Unknown Date';
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PDFViewerPage(
                      //         pdfFile: pdfFile), // Pass PDFFile object
                      //   ),
                      // );
                    },
                    child: Container(
                      height: height * 0.1,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: width * 0.02),
                            child: Container(
                              height: height * 0.08,
                              width: width * 0.19,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                              ),
                              child: Icon(
                                FontAwesomeIcons.filePdf,
                                color: Colors
                                    .red, // Ensure this is defined somewhere
                                size: height * 0.04,
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: width * 0.38,
                                  child: Text(
                                    decodeFileName(fileName),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.38,
                                  child: Text(
                                    uploadDate,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade300,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  //  ListTile(
                  //   title: Text(
                  //     decodeFileName(fileName),
                  //     style: TextStyle(fontFamily: 'NotoSansArabic'),
                  //   ),
                  //   subtitle: Text(uploadDate),
                  // );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
