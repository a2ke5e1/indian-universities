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
  final GlobalKey<_UniversityListFilterState> _universityListFilterKey =
      GlobalKey<_UniversityListFilterState>();

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
    NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: "Home"),
    NavigationDestination(
        icon: Icon(Icons.bookmark_border),
        selectedIcon: Icon(Icons.bookmark),
        label: "Bookmarks"),
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
                IconButton(
                  onPressed: () {
                    _universityListFilterKey.currentState?.openFilterDialog();
                  },
                  icon: const Icon(Icons.filter_list),
                ),
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
              UniversityListFilter(
                universityRepo: universityRepo,
                key: _universityListFilterKey,
              ),
              FavoritesList(universityRepo: universityRepo),
              const AccountInfo(),
            ][_navigationIndex],
            bottomNavigationBar: NavigationBar(
              surfaceTintColor: Theme.of(context).colorScheme.primary,
              destinations: _items,
              onDestinationSelected: _onNavigationTap,
              selectedIndex: _navigationIndex,
            ),
          );
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
            Icon(
              Icons.bookmark_border,
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const Text("Login to view your bookmarks"),
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
        emptyBuilder: (context) => Center(
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text("No bookmarks!"),
                ],
              ),
            ),
        itemBuilder: (context, doc) {
          var uni = doc.data();
          return ListTile(
            title: Text(uni.University_Name.toString()),
            trailing: IconButton(
              onPressed: () {
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
                    });
              },
              icon: const Icon(Icons.delete),
            ),
            onTap: () {
              print(uni);
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
  late Future<List<Details>> _universityDetails;

  @override
  void initState() {
    super.initState();
    _universityDetails = _universityLoader.loadUniversityDetails();
  }

  @override
  Widget build(BuildContext context) {
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
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final university = data[index];
              return ListTile(
                  title: Text(university.University_Name ?? ''),
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
                  onLongPress: () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Add to Favorites"),
                                content: Text(
                                    "Do you want to add ${university.University_Name} to favorites?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("No")),
                                  TextButton(
                                      onPressed: () {
                                        widget.universityRepo
                                            .addFavourite(university);
                                        Navigator.pop(context);
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

extension StringExtensions on String {
  String toSentenceCase() {
    List<String> words = split(" ");
    for (int i = 0; i < words.length; i++) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
    return words.join(" ");
  }
}

class UniversityListFilter extends StatefulWidget {
  final FireStoreDataBase universityRepo;

  const UniversityListFilter({super.key, required this.universityRepo});

  @override
  _UniversityListFilterState createState() => _UniversityListFilterState();
}

class _UniversityListFilterState extends State<UniversityListFilter> {
  final UniversityLoader _universityLoader = UniversityLoader();
  late Future<Map<String, List<Details>>> _universityDetails;
  List<Details> _favouriteUniversities = [];
  String? selectedState;
  String? selectedUniversityType;

  @override
  void initState() {
    super.initState();
    widget.universityRepo.getFavouriteData().then((value) {
      setState(() {
        _favouriteUniversities = value;
      });
    });
    _universityDetails =
        _universityLoader.loadUniversityDetails().then((value) {
      return _universityLoader.getUniversitiesByState(value);
    });
  }

  bool isFavourite(String? universityId) {
    return _favouriteUniversities
        .any((element) => element.docId == universityId);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Universities"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                hint: const Text("Select State"),
                value: selectedState,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedState = newValue;
                  });
                },
                items: _universityLoader
                    .getStates()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                hint: const Text("Select University Type"),
                value: selectedUniversityType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUniversityType = newValue;
                  });
                },
                items: _universityLoader
                    .getUniversityTypes()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _universityDetails =
                      _universityLoader.loadUniversityDetails().then((value) {
                    return _universityLoader.filterUniversities(
                        value, selectedState, selectedUniversityType);
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedState = null;
                  selectedUniversityType = null;
                  _universityDetails =
                      _universityLoader.loadUniversityDetails().then((value) {
                    return _universityLoader.getUniversitiesByState(value);
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Details>>>(
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
          final sortedKeys = data.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              final universities = data[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Text(
                      key.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  ...universities.map((university) => ListTile(
                        title: Text(
                            university.University_Name?.toUpperCase() ?? ''),
                        trailing: FirebaseAuth
                                    .instance.currentUser?.isAnonymous ??
                                true
                            ? const SizedBox()
                            : isFavourite(university.docId)
                                ? IconButton(
                                    onPressed: () {
                                      widget.universityRepo
                                          .removeFavourite(university);
                                      setState(() {
                                        _favouriteUniversities.removeWhere(
                                            (element) =>
                                                element.University_Name ==
                                                university.University_Name);
                                      });
                                      _showSnackBar(
                                          context, "Removed from Bookmarks");
                                    },
                                    icon: const Icon(Icons.bookmark))
                                : IconButton(
                                    onPressed: () {
                                      widget.universityRepo
                                          .addFavourite(university);
                                      setState(() {
                                        _favouriteUniversities.add(university);
                                      });
                                      _showSnackBar(
                                          context, "Added to Bookmarks");
                                    },
                                    icon: const Icon(Icons.bookmark_border)),
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
                      ))
                ],
              );
            },
          );
        }
      },
    );
  }
}

class AccountInfo extends StatelessWidget {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      return Container(
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
            margin: const EdgeInsets.only(right: 19),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Name"),
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
