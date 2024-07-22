import 'package:flutter/material.dart';
import 'package:grade_tracker/ViewModel/StudentSearchViewModel.dart';
import 'package:provider/provider.dart';

class StudentSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentSearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => viewModel.searchStudents(query),
              decoration: const InputDecoration(
                labelText: 'Search Students By Name',
                suffixIcon: Icon(Icons.search),
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
