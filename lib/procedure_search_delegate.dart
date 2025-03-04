import 'package:flutter/material.dart';
import 'procedure_detail_screen.dart';

class ProcedureSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> procedures;

  ProcedureSearchDelegate(this.procedures);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = procedures.where((procedure) {
      final name = procedure['name'].toString().toLowerCase();
      final keywords = (procedure['keywords'] as List<dynamic>)
          .map((keyword) => keyword.toString().toLowerCase())
          .toList();

      return name.contains(query.toLowerCase()) ||
          keywords.any((keyword) => keyword.contains(query.toLowerCase()));
    }).toList();

    return results.isEmpty
        ? const Center(child: Text('No results found'))
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final procedure = results[index];
              return ListTile(
                title: Text(procedure['name']),
                subtitle: Text(procedure['description']),
                onTap: () {
                  close(context, procedure);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProcedureDetailScreen(procedure),
                    ),
                  );
                },
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = procedures.where((procedure) {
      final name = procedure['name'].toString().toLowerCase();
      final keywords = (procedure['keywords'] as List<dynamic>)
          .map((keyword) => keyword.toString().toLowerCase())
          .toList();

      return name.contains(query.toLowerCase()) ||
          keywords.any((keyword) => keyword.contains(query.toLowerCase()));
    }).toList();

    return suggestions.isEmpty
        ? const Center(child: Text('No suggestions'))
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final procedure = suggestions[index];
              return ListTile(
                title: Text(procedure['name']),
                subtitle: Text(procedure['description']),
                onTap: () {
                  query = procedure['name'];
                  showResults(context);
                },
              );
            },
          );
  }
}
