import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian_universities/components/about.dart';
import 'package:indian_universities/models/details.dart';
import 'package:indian_universities/screens/search.dart';
import 'package:indian_universities/services/auth_service.dart';
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
                              delegate: CustomSearchDelegate(
                                  navigationIndex: _navigationIndex));
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
              UniversityList(universityRepo: universityRepo),
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
