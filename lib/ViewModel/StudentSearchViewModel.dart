import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentSearchViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;

  Future<void> searchStudents(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _currentQuery = query;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/search_students.php?query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _searchResults = List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to search students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching students: $e');
      // Ideally, you should notify listeners about the error as well
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  TextSpan buildHighlightedName(String name, String query) {
    if (query.isEmpty) return TextSpan(text: name);

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

    return TextSpan(
      style: TextStyle(fontSize: 16, color: Colors.black),
      children: spans,
    );
  }
}
