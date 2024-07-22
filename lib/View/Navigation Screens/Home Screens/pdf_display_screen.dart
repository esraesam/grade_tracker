import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:grade_tracker/Model/pdfFile.dart';
import 'package:grade_tracker/widgets/Home/search_textFormField_widget.dart';

class DisplayPdfScreen extends StatefulWidget {
  const DisplayPdfScreen({Key? key}) : super(key: key);

  @override
  State<DisplayPdfScreen> createState() => _DisplayPdfScreenState();
}

class _DisplayPdfScreenState extends State<DisplayPdfScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<List<PDFFile>>? _searchResults;

  Future<List<PDFFile>> searchPdfs(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/search_pdfs.php'),
        body: {'query': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        print('Search results: $results');
        return results
            .map((json) => PDFFile(name: json['name'], url: json['url']))
            .toList();
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print('Search error: $e');
      throw Exception('Error fetching search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Text(
          'Search PDFs',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchTextfieldWidget(
            height: height,
            width: width,
            searchController: _searchController,
            onChanged: (query) {
              setState(() {
                _searchResults = searchPdfs(query);
              });
            },
          ),
          SizedBox(height: height * 0.01),
          Expanded(
            child: FutureBuilder<List<PDFFile>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No PDFs found.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        PDFFile pdfFile = snapshot.data![index];
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
                                SizedBox(
                                  width: width * 0.38,
                                  child: Text(
                                    pdfFile.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: height * 0.01);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
