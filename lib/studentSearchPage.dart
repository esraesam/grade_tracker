import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentSearchPage extends StatefulWidget {
  @override
  _StudentSearchPageState createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchStudents(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/search_students.php?query=$query'),
      );
      print('response ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('data $data');
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        throw Exception('Failed to search students');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching students: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchStudents,
              decoration: InputDecoration(
                labelText: 'Search Students',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: _highlightOccurrences(
                              result['name'],
                              result['highlighted_name'],
                            ),
                            style: DefaultTextStyle.of(context).style,
                          ),
                        ),
                        subtitle: Text(result['file_name']),
                        onTap: () {
                          // Open PDF file using result['file_url']
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightOccurrences(String text, String highlighted) {
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = text.indexOf(highlighted, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      spans.add(TextSpan(
        text: text.substring(
            indexOfHighlight, indexOfHighlight + highlighted.length),
        style: TextStyle(
            fontWeight: FontWeight.bold, backgroundColor: Colors.yellow),
      ));
      start = indexOfHighlight + highlighted.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
