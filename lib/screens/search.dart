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
  late Future<List<Details>> _universityDetails;

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

    return FutureBuilder<List<Details>>(
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
              .where((university) => university.University_Name
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
              .toList();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                title: Text(university.University_Name.toString()), // Assuming the first column is the university name
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {
                      'University_Id': university.docId,
                      'University_Name': university.University_Name,
                      'University_Type': university.University_Type,
                      'State': university.State,
                      'Location': university.Location,
                      'District': university.District,
                      'Address': university.address,
                      'Website': university.website,
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

    return FutureBuilder<List<Details>>(
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
              .where((university) => university.University_Name
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
              .toList();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                title: Text(university.University_Name.toString()), // Assuming the first column is the university name
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {
                      'University_Id': university.docId,
                      'University_Name': university.University_Name,
                      'University_Type': university.University_Type,
                      'State': university.State,
                      'Location': university.Location,
                      'District': university.District,
                      'Address': university.address,
                      'Website': university.website,
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