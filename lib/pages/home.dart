import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian_universities/components/about.dart';
import 'package:indian_universities/models/details.dart';
import 'package:indian_universities/screens/search.dart';
import 'package:indian_universities/services/auth_service.dart';
import 'package:indian_universities/services/unirepo.dart';
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
    print(user);
    super.initState();
  }

  Future<void> _initShare() async {
    prefs = await SharedPreferences.getInstance();
  }

  static const _items = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
    // NavigationDestination(icon: Icon(Icons.person), label: "Account")
  ];

  int _navigationIndex = 0;
  String title = _items[0].label;

  void _onNavigationTap(int index) {
    setState(() {
      _navigationIndex = index;
      title = _items[index].label;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlePopupMenu(int value) {
    switch (value) {
      case 0:
        {
          About(context).showCustomDialogBox();
          break;
        }
      case 1:
        {
          AuthService.logout();
          Navigator.pushNamedAndRemoveUntil(
              context, '/signin', (route) => false);

          break;
        }
      case 2:
        {
          AuthService.logout();
          setState(() {
            _onNavigationTap(0);
          });
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                _navigationIndex == 0
                    ? IconButton(
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: CustomSearchDelegate());
                        },
                        icon: const Icon(Icons.search))
                    : Container(),
                PopupMenuButton<int>(
                  onSelected: handlePopupMenu,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Text("About"),
                    ),
                    FirebaseAuth.instance.currentUser?.isAnonymous ?? true
                        ? const PopupMenuItem(
                            value: 1,
                            child: Text("Login"),
                          )
                        : const PopupMenuItem(
                            value: 2,
                            child: Text("Logout"),
                          )
                  ],
                )
              ],
            ),
            body: <Widget>[
              UniversityList(
                universityRepo: universityRepo,
              ),
              FavoritesList(universityRepo: universityRepo),
              AccountInfo(),
            ][_navigationIndex],
            bottomNavigationBar: NavigationBar(
              destinations: _items,
              onDestinationSelected: _onNavigationTap,
              selectedIndex: _navigationIndex,
            ),
          );
          ;
        });
  }
}

class FavoritesList extends StatelessWidget {
  final FireStoreDataBase universityRepo;

  const FavoritesList({super.key, required this.universityRepo});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      return Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text("Please login to view favorites"),
            const SizedBox(
              height: 10,
            ),
            FilledButton.tonal(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                child: const Text("Login"))
          ],
        ),
      );
    }

    return FirestoreListView<Details>(
        query: universityRepo.favouriteref,
        pageSize: 25,
        loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
        emptyBuilder: (context) => const Center(
              child: Text("No favorites added"),
            ),
        itemBuilder: (context, doc) {
          var uni = doc.data();
          return ListTile(
            title: Text(uni.University_Name.toString()),
            onTap: () {
              print(uni );
              Navigator.pushNamed(
                context,
                '/details',
                arguments: {
                  'University_Id': uni.docId,
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

class UniversityList extends StatefulWidget {
  final FireStoreDataBase universityRepo;

  const UniversityList({super.key, required this.universityRepo});

  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  final UniversityLoader _universityLoader = UniversityLoader();
  late Future<List<List<dynamic>>> _universityDetails;

  @override
  void initState() {
    super.initState();
    _universityDetails = _universityLoader.loadUniversityDetails();
  }

  @override
  Widget build(BuildContext context) {
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
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                  title: Text(university[1].toString()),
                  // Assuming the first column is the university name
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
                  onLongPress: () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Add to Favorites"),
                                content: Text(
                                    "Do you want to add ${university[1]} to favorites?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("No")),
                                  TextButton(
                                      onPressed: () {
                                        widget.universityRepo.addFavourite(
                                            Details(
                                                docId: university[0],
                                                University_Type: university[5],
                                                State: university[2],
                                                Location: university[7],
                                                District: university[3],
                                                address: university[8],
                                                website: university[4],
                                                University_Name:
                                                    university[1]));
                                        Navigator.pop(context, {
                                          'University_Name': university[1],
                                          'University_Type': university[5],
                                          'State': university[2],
                                          'Location': university[7],
                                          'District': university[3],
                                          'Address': university[8],
                                          'Website': university[4],
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
