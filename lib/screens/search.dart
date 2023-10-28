import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:indian_universities/services/firestore.dart';
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
  int navigationIndex = 1;
  FireStoreDataBase universityRepo = FireStoreDataBase();
  CustomSearchDelegate({required this.navigationIndex});

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
      return ListView(); // Return null when the search query is empty
    }

    return FirestoreListView<Details>(
      query: navigationIndex == 1
          ? universityRepo.universityRef.startAt([query.toUpperCase()]).endAt(
              ['${query.toUpperCase()}\uf8ff']).limit(10)
          : universityRepo.favouriteref
              .orderBy("University_Name")
              .startAt([query.toUpperCase()]).endAt(
                  ['${query.toUpperCase()}\uf8ff']).limit(10),
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      pageSize: 10,
      itemBuilder: (context, doc) {
        var uni = doc.data();
        return ListTile(
            title: Text(uni.University_Name.toString()),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
                arguments: {
                  'University_Name': uni.University_Name,
                  'University_Type': uni.University_Type,
                  'State': uni.State,
                  'Location': uni.Location,
                  'District': uni.District,
                  'Address': uni.address,
                  'Website': uni.website,
                },
              );
            },
            onLongPress: () => {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Add to Favorites"),
                          content: Text(
                              "Do you want to add ${uni.University_Name} to favorites?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No")),
                            TextButton(
                                onPressed: () {
                                  universityRepo.addFavourite(uni);
                                  Navigator.pop(context, {
                                    'University_Name': uni.University_Name,
                                    'University_Type': uni.University_Type,
                                    'State': uni.State,
                                    'Location': uni.Location,
                                    'District': uni.District,
                                    'Address': uni.address,
                                    'Website': uni.website,
                                  });
                                },
                                child: const Text("Yes"))
                          ],
                        );
                      })
                });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(); // Return null when the search query is empty
    }

    return FirestoreListView<Details>(
      query: navigationIndex == 1
          ? universityRepo.universityRef.startAt([query.toUpperCase()]).endAt(
              ['${query.toUpperCase()}\uf8ff']).limit(10)
          : universityRepo.favouriteref
              .orderBy("University_Name")
              .startAt([query.toUpperCase()]).endAt(
                  ['${query.toUpperCase()}\uf8ff']).limit(10),
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      pageSize: 10,
      itemBuilder: (context, doc) {
        var uni = doc.data();
        return ListTile(
            title: Text(uni.University_Name.toString()),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
                arguments: {
                  'University_Name': uni.University_Name,
                  'University_Type': uni.University_Type,
                  'State': uni.State,
                  'Location': uni.Location,
                  'District': uni.District,
                  'Address': uni.address,
                  'Website': uni.website,
                },
              );
            },
            onLongPress: () => {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Add to Favorites"),
                          content: Text(
                              "Do you want to add ${uni.University_Name} to favorites?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No")),
                            TextButton(
                                onPressed: () {
                                  universityRepo.addFavourite(uni);
                                  Navigator.pop(context, {
                                    'University_Name': uni.University_Name,
                                    'University_Type': uni.University_Type,
                                    'State': uni.State,
                                    'Location': uni.Location,
                                    'District': uni.District,
                                    'Address': uni.address,
                                    'Website': uni.website,
                                  });
                                },
                                child: const Text("Yes"))
                          ],
                        );
                      })
                });
      },
    );
  }
}
