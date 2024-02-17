import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indian_universities/auth/verify_email.dart';
import 'package:indian_universities/models/details.dart';
import 'package:indian_universities/screens/search.dart';
import 'package:indian_universities/services/auth.dart';
import 'package:local_auth/local_auth.dart';
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
  final LocalAuthentication auth = LocalAuthentication();
  bool biometric = false;
  FireStoreDataBase universityRepo = FireStoreDataBase();
  final AuthService _auth = AuthService();
  bool renderHome = false;
  late SharedPreferences prefs;
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    _initShare();
    super.initState();
  }

  Future<void> _initShare() async {
    prefs = await SharedPreferences.getInstance();
    await _authenticate();
  }

  Future<void> _isAppLockEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAppLockEnabled = prefs.getBool('isAppLockEnabled');
    if (isAppLockEnabled == null) {
      prefs.setBool('isAppLockEnabled', false);
      setState(() {
        biometric = false;
      });
    } else {
      setState(() {
        biometric = isAppLockEnabled;
      });
    }
  }

  Future<void> _authenticate() async {
    await _isAppLockEnabled();
    if (!biometric) {
      setState(() {
        renderHome = true;
      });
      return;
    }

    bool authenticated = false;

    bool isSupported = await auth.isDeviceSupported();
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (!isSupported || availableBiometrics.isEmpty) {
      setState(() {
        renderHome = true;
      });
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        authenticated = await auth.authenticate(
            localizedReason: 'Please authenticate to show account balance',
            options: const AuthenticationOptions(biometricOnly: true));
        setState(() {
          renderHome = authenticated ? true : false;
        });
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  static const _items = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    NavigationDestination(icon: Icon(Icons.search), label: "Search"),
    NavigationDestination(icon: Icon(Icons.person), label: "Account")
  ];

  int _navigationIndex = 0;
  String title = "Favorites";

  void _onNavigationTap(int index) {
    if (FirebaseAuth.instance.currentUser!.emailVerified ||
        FirebaseAuth.instance.currentUser!.isAnonymous) {
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return renderHome
        ? Scaffold(
            appBar: AppBar(
              title: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              centerTitle: true,
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
                    await _auth.signOut();
                  },
                  icon: const Icon(Icons.person),
                  label: const Text("Logout"),
                )
              ],
            ),
            body: <Widget>[
              FirebaseAuth.instance.currentUser!.isAnonymous
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Please login to use Favourites feature"),
                        ],
                      ),
                    )
                  : FirebaseAuth.instance.currentUser!.emailVerified
                      ? FirestoreListView<Details>(
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
                                        title:
                                            const Text("Remove from Favorites"),
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
                                                setState(
                                                  () {
                                                    universityRepo
                                                        .removeFavourite(uni);
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                              child: const Text("Yes"))
                                        ],
                                      );
                                    })
                              },
                            );
                          })
                      : const EmailVerificationScreen(),
              FirestoreListView<Details>(
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
                                            setState(
                                              () {
                                                universityRepo
                                                    .addFavourite(uni);
                                                Navigator.pop(context, {
                                                  'University_Name':
                                                      uni.University_Name,
                                                  'University_Type':
                                                      uni.University_Type,
                                                  'State': uni.State,
                                                  'Location': uni.Location,
                                                  'District': uni.District,
                                                  'Address': uni.address,
                                                  'Website': uni.website,
                                                });
                                              },
                                            );
                                          },
                                          child: const Text("Yes"))
                                    ],
                                  );
                                })
                          });
                },
              ),
              FirebaseAuth.instance.currentUser!.isAnonymous
                  ? Scaffold(
                      body: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Card(
                              child: SizedBox(
                                child: Center(
                                  child:
                                      Text("Account information not available"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            !kIsWeb
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            20.0, 0, 0, 0),
                                        child: Text(
                                          "App Lock",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                      Switch(
                                          value: biometric,
                                          onChanged: (bool value) async {
                                            setState(() {
                                              biometric = value;
                                              prefs.setBool(
                                                  'isAppLockEnabled', value);
                                            });
                                          })
                                    ],
                                  )
                                : Row(),
                          ]),
                    ))
                  : Scaffold(
                      body: Container(
                      margin: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                      child: Column(
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Card(
                                margin: EdgeInsets.only(right: 19),
                                child: ListTile(
                                    title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Name"),
                                    Text(
                                        "${FirebaseAuth.instance.currentUser!.displayName}")
                                  ],
                                ))),
                            const SizedBox(height: 20.0),
                            !kIsWeb
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "App Lock",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      Switch(
                                          value: biometric,
                                          onChanged: (bool value) async {
                                            setState(() {
                                              biometric = value;
                                              prefs.setBool(
                                                  'isAppLockEnabled', value);
                                            });
                                          })
                                    ],
                                  )
                                : Row()
                          ]),
                    ))
            ][_navigationIndex],
            bottomNavigationBar: NavigationBar(
              destinations: _items,
              onDestinationSelected: _onNavigationTap,
              selectedIndex: _navigationIndex,
            ),
          )
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please authenticate to use App"),
                  ElevatedButton(
                    onPressed: () {
                      _authenticate();
                    },
                    child: const Text("Authenticate"),
                  )
                ],
              ),
            ),
          );
  }

  Future<List<BiometricType>> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    print(availableBiometrics);
    return availableBiometrics;
  }
}
