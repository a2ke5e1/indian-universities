import 'package:flutter/material.dart';
import 'package:indian_universities/services/unirepo.dart'; // Import the UniversityLoader class

import '../models/details.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final UniversityLoader _universityLoader = UniversityLoader();
  late Future<List<List<dynamic>>> _universityDetails;

  CustomSearchDelegate() {
    _universityDetails = _universityLoader.loadUniversityDetails();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return ListView(); // Return empty ListView when the search query is empty
    }

    return FutureBuilder<List<List<dynamic>>>(
      future: _universityDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No university details available'));
        } else {
          final data = snapshot.data!
              .where((university) => university[1]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
              .toList();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                title: Text(university[1].toString()), // Assuming the first column is the university name
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {
                      'University_Id': university[0],
                      'University_Name': university[1],
                      'University_Type': university[5],
                      'State': university[2],
                      'Location': university[7],
                      'District': university[3],
                      'Address': university[8],
                      'Website': university[4],
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(); // Return empty ListView when the search query is empty
    }

    return FutureBuilder<List<List<dynamic>>>(
      future: _universityDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No university details available'));
        } else {
          final data = snapshot.data!
              .where((university) => university[1]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
              .toList();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                title: Text(university[1].toString()), // Assuming the first column is the university name
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {
                      'University_Id': university[0],
                      'University_Name': university[1],
                      'University_Type': university[5],
                      'State': university[2],
                      'Location': university[7],
                      'District': university[3],
                      'Address': university[8],
                      'Website': university[4],
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}