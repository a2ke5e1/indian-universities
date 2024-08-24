import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian_universities/models/details.dart';
import 'package:indian_universities/screens/search.dart';
import 'package:indian_universities/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResend = true;
  Timer? resendTimer;
  int resendTime = 60;
  Timer? countDownTimer;

  bool isAnon = false;
  FireStoreDataBase universityRepo = FireStoreDataBase();
  final AuthService _auth = AuthService();
  bool renderHome = false;
  late SharedPreferences prefs;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _initShare();
    super.initState();
  }

  Future<void> _initShare() async {
    prefs = await SharedPreferences.getInstance();
  }

  static const _items = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    NavigationDestination(icon: Icon(Icons.search), label: "Search"),
    NavigationDestination(icon: Icon(Icons.person), label: "Account")
  ];

  int _navigationIndex = 1;
  String title = "Search";

  void _onNavigationTap(int index) {
    setState(() {
      _navigationIndex = index;
      switch (index) {
        case 0:
          title = "Favorites";
          break;
        case 1:
          title = "Search";
          break;
        case 2:
          title = "Account";
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          _navigationIndex != 2
              ? IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(
                            navigationIndex: _navigationIndex));
                  },
                  icon: const Icon(Icons.search))
              : Container(),
          ElevatedButton.icon(
            onPressed: () async {
              if (user == null) {
                Navigator.pushNamed(context, '/auth');
              } else {
                await _auth.signOut();
              }
            },
            icon: const Icon(Icons.person),
            label: Text(user == null ? "Login" : "Logout"),
          )
        ],
      ),
      body: <Widget>[
        FavoritesList(universityRepo: universityRepo),
        UniversityList(universityRepo: universityRepo),
        AccountInfo(),
      ][_navigationIndex],
      bottomNavigationBar: NavigationBar(
        destinations: _items,
        onDestinationSelected: _onNavigationTap,
        selectedIndex: _navigationIndex,
      ),
    );
  }
}

class FavoritesList extends StatelessWidget {
  final FireStoreDataBase universityRepo;

  const FavoritesList({super.key, required this.universityRepo});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      return const Center(
        child: Text("Please login to view favorites"),
      );
    }

    return FirestoreListView<Details>(
        query: universityRepo.favouriteref,
        pageSize: 25,
        loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
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
                      title: const Text("Remove from Favorites"),
                      content: Text(
                          "Do you want to remove ${uni.University_Name} from favorites?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () {
                              universityRepo.removeFavourite(uni);
                              Navigator.pop(context);
                            },
                            child: const Text("Yes"))
                      ],
                    );
                  })
            },
          );
        });
  }
}

class UniversityList extends StatelessWidget {
  final FireStoreDataBase universityRepo;

  const UniversityList({required this.universityRepo});

  @override
  Widget build(BuildContext context) {
    return FirestoreListView<Details>(
      query: universityRepo.universityRef,
      pageSize: 25,
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      itemBuilder: (context, doc) {
        var uni = doc.data();
        return ListTile(
          title: Text(uni.getUniversityName().toString()),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/details',
              arguments: {
                'University_Id': uni.getUniversityID(),
                'University_Name': uni.getUniversityName(),
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
          },
        );
      },
    );
  }
}

class AccountInfo extends StatelessWidget {
  const AccountInfo();

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text("Account information not available"),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.only(right: 19),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name"),
                  Text("${FirebaseAuth.instance.currentUser!.displayName}")
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
