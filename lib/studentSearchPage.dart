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
  String _currentQuery = '';

  Future<void> _searchStudents(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/search_students.php?query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        throw Exception('Failed to search students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching students: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget _buildHighlightedName(String name, String query) {
    if (query.isEmpty) return Text(name);

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery =
            name.toLowerCase().indexOf(query.toLowerCase(), start)) !=
        -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: name.substring(start, indexOfQuery)));
      }
      spans.add(TextSpan(
        text: name.substring(indexOfQuery, indexOfQuery + query.length),
        style: TextStyle(
            backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
      ));
      start = indexOfQuery + query.length;
    }

    if (start < name.length) {
      spans.add(TextSpan(text: name.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
    );
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
              decoration: const InputDecoration(
                labelText: 'Search Students By Name',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: _buildHighlightedName(
                            result['name'], _currentQuery),
                        subtitle: Text(result['file_name']),
                        onTap: () {
                          // TODO: Implement PDF opening logic
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
