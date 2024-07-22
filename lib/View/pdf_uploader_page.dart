// views/pdf_uploader_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grade_tracker/View/StudentSearchPage.dart';
import 'package:grade_tracker/ViewModel/pdf_uploader_viewmodel.dart';
import 'package:grade_tracker/studentSearchPage.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PDFUploaderPage extends StatelessWidget {
  const PDFUploaderPage({Key? key}) : super(key: key);

  String decodeFileName(String fileName) {
    try {
      return utf8.decode(fileName.codeUnits);
    } catch (e) {
      print('Error decoding file name: $e');
      return fileName;
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => PDFUploaderViewModel()..fetchIndexedFiles(),
      child: Scaffold(
        floatingActionButton: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentSearchPage()),
            );
          },
          child: Container(
            height: height * 0.06,
            width: width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.blue,
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
        body: Consumer<PDFUploaderViewModel>(
          builder: (context, viewModel, child) {
            return Column(
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
                    onPressed: viewModel.isUploading
                        ? null
                        : () => viewModel.uploadAndIndexPDF(context),
                    child: Text(
                        viewModel.isUploading ? 'Uploading...' : 'Upload PDF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: ListView.builder(
                      itemCount: viewModel.indexedFiles.length,
                      itemBuilder: (context, index) {
                        final file = viewModel.indexedFiles[index];
                        return GestureDetector(
                          onTap: () {
                            // Handle file tap
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
                                      color: Colors.red,
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
                                          decodeFileName(file.fileName),
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
                                          file.uploadDate,
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
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
