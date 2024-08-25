import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGate extends StatelessWidget {
  Widget child;

  AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return child;
        });
  }
}

class AuthService {
  static Future<UserCredential?> signupWithGoogle(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      return await auth.signInWithCredential(authCredential);
    }
    return null;
  }

  static void signInAnonIfNotSignedIn() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return;
      }
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  // A static Logout function for the app
  static void logout() async {
    GoogleSignIn().signOut();
    FirebaseAuth.instance.signOut();
  }
}
