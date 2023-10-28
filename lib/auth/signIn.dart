import 'package:indian_universities/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import '../constants/Strings.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _signInFormKey = GlobalKey<FormState>();
  bool someError = false;
  String errorMessage = "";
  bool wrongEmailPassword = false;

  void handleLogin() async {
    if (_signInFormKey.currentState!.validate()) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The loading indicator
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text('Loading...')
                  ],
                ),
              ),
            );
          });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
        setState(() {
          wrongEmailPassword = true;
        });
      } catch (e) {
        print(e);
      }

      // Remove Dialogbox after user logged in.
      Navigator.of(context).pop();
    }
  }

  final AuthService _auth = AuthService();
  void handleGoogleSignIn() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });

    try {
      await AuthGoogle.signupWithGoogle(context);
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      setState(() {
        someError = true;
        if (e.code == 'weak-password' ||
            e.message.toString().contains("weak-password")) {
          errorMessage = Strings.AUTH_WEAK_PASSWORD;
        } else if (e.code == 'email-already-in-use' ||
            e.message.toString().contains("email-already-in-use")) {
          errorMessage = Strings.AUTH_EMAIL_ALREADY_IN_USE;
        } else if (e.message.toString().contains("auth/too-many-requests")) {
          errorMessage = Strings.AUTH_TOO_MANY_REQUESTS;
        } else if (e.message.toString().contains("network error")) {
          errorMessage = Strings.AUTH_NETWORK_ERROR;
        } else {
          errorMessage = e.message.toString();
        }
      });
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      debugPrint(e.toString());
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    /* This is used to prevent users loading sign in page
    *  when user is already logged in.
    *
    *  This behaviour is designed for web browsers.
    *  For mobile devices it is not possible to reach this state. */

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _signInFormKey,
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sign In",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    wrongEmailPassword
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(Strings.WRONG_EMAIL_PASSWORD,
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: emailController,
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter email";
                              }
                              if (!EmailValidator.validate(value)) {
                                return "Please enter valid email";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: passwordController,
                            autofillHints: const [AutofillHints.password],
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password'),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 45,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/signup");
                                },
                                child: const Text("Not Registered? Register.")),
                          ),
                          SizedBox(
                            height: 45,
                            child: FilledButton.tonal(
                                onPressed: handleLogin,
                                child: const Text("Login")),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: FilledButton.tonal(
                              child: const Text("Sign in as Guest"),
                              onPressed: () async {
                                dynamic result = await _auth.signInAnon();
                                if (result == null) {
                                  print('error signing in');
                                } else {
                                  print('signed in');
                                  print(result.uid);
                                }
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: FilledButton.tonal(
                                onPressed: handleGoogleSignIn,
                                child: Text("Signin with Google")),
                          )
                        ]),
                    const SizedBox(height: 5),
                    Center(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FilledButton.tonal(
                            child: const Text("Forgotten Password?"),
                            onPressed: () {
                              Navigator.pushNamed(context, '/reset');
                            },
                          )),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus varius.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Terms of Service",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Padding(padding: EdgeInsets.all(4), child: Text("·")),
                          Text(
                            "Privacy Policy",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
