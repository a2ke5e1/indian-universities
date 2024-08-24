import 'package:email_validator/email_validator.dart';
import 'package:indian_universities/components/about.dart';
import 'package:indian_universities/constants/Strings.dart';
import 'package:indian_universities/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/footer.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _signInFormKey = GlobalKey<FormState>();

  bool error = false;
  String? errorMessage;

  /// This function is used to authenticate the user
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
        TextInput.finishAutofillContext();
        Navigator.of(context, rootNavigator: true).pop();
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = true;
          if (e.message.toString().contains("auth/wrong-password") ||
              e.message.toString().contains("auth/user-not-found") ||
              e.message.toString().contains("auth/invalid-email") ||
              e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-email') {
            errorMessage = Strings.WRONG_EMAIL_PASSWORD;
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
  }

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
      await AuthService.signupWithGoogle(context)
          .then((value) => Navigator.of(context, rootNavigator: true).pop());
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = true;
        if (e.message.toString().contains("auth/wrong-password") ||
            e.message.toString().contains("auth/user-not-found") ||
            e.message.toString().contains("auth/invalid-email") ||
            e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-email') {
          errorMessage = Strings.WRONG_EMAIL_PASSWORD;
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
  void initState() {
    super.initState();
  }

  void handlePopupMenu(int value) {
    switch (value) {
      case 0:
        {
          About(context).showCustomDialogBox();
          break;
        }

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
    if (user != null) {
      Navigator.pop(context);
      return Text("Invalid State");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            onSelected: handlePopupMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text('About')),
            ],
          )
        ],
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
                      padding: EdgeInsets.all(8.0),
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
                            "Welcome back to Eye Care!\nPlease sign in to continue.",
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
                    error
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(errorMessage ?? "",
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
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
                            onChanged: (value) {
                              setState(() {
                                error = false;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email'),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
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
                            onChanged: (value) {
                              setState(() {
                                error = false;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password'),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/resetpassword");
                        },
                        child: Text("Forgot Password?")),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 45,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/signup");
                                },
                                child: Text("Not Registered? Register.")),
                          ),
                          SizedBox(
                            height: 45,
                            child: FilledButton.tonal(
                                onPressed: handleLogin, child: Text("Login")),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton.icon(
                            onPressed: handleGoogleSignIn,
                            icon: Image.asset(
                              "assets/images/google.png",
                              height: 24,
                            ),
                            label: const Text("Sign In with Google")),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Footer(
                          footerMessage:
                              "Eye Care is developed by A3 Group. "),
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
