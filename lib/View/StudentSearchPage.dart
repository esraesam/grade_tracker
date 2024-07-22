import 'package:flutter/material.dart';
import 'package:grade_tracker/ViewModel/StudentSearchViewModel.dart';
import 'package:provider/provider.dart';

class StudentSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentSearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Search',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => viewModel.searchStudents(query),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                filled: true,
                fillColor: const Color.fromARGB(255, 240, 240, 241),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                hintText: "Search by name",
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9F9A9A),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF9F9A9A),
                ),
              ),
            ),
          ),
          Expanded(
            child: viewModel.isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: viewModel.searchResults.length,
                    itemBuilder: (context, index) {
                      final result = viewModel.searchResults[index];
                      return ListTile(
                        title: Text.rich(
                          viewModel.buildHighlightedName(
                              result['name'], viewModel.currentQuery),
                        ),
                        subtitle: Text(result['file_name']),
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
