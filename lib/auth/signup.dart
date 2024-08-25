import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indian_universities/components/about.dart';
import 'package:indian_universities/components/footer.dart';
import 'package:indian_universities/constants/Strings.dart';
import 'package:indian_universities/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _signUpFormKey = GlobalKey<FormState>();

  bool someError = false;
  String errorMessage = "";

  void handleSignup() async {
    if (_signUpFormKey.currentState!.validate()) {
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
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.toString(),
          password: confirmPasswordController.text.toString(),
        );
        final user = credential.user;
        user?.updateDisplayName(nameController.text);
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil("/home", (route) => false);
        TextInput.finishAutofillContext();
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
      await AuthService.signupWithGoogle(context);
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog

      // Goes back to home page
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
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
    /* This is used to prevent users loading sign up page
    *  when user is already logged in.
    *
    *  This behaviour is designed for web browsers.
    *  For mobile devices it is not possible to reach this state. */
    if (user != null) {
      Navigator.pop(context);
      return const Text("Invalid State");
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
          key: _signUpFormKey,
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
                            "Sign Up",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Keep track of your favorites universities by creating an account. You can sign up with your email or with your Google account.",
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
                    someError
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(errorMessage,
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
                            controller: nameController,
                            autofillHints: const [AutofillHints.name],
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter name";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                someError = false;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name'),
                          ),
                        ),
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
                            onChanged: (value) {
                              setState(() {
                                someError = false;
                              });
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
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              }
                              if (value.length < 8) {
                                return "Password must be 8 characters long";
                              }
                              RegExp regex = RegExp(
                                  r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$");
                              if (!regex.hasMatch(value)) {
                                return Strings.PASSWORD_RULES;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                someError = false;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (passwordController.text.toString() !=
                                  confirmPasswordController.text.toString()) {
                                return "Confirm Password does not match";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                someError = false;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Confirm Password'),
                          ),
                        )
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
                                  Navigator.pop(context);
                                },
                                child: const Text("Already Registered? Login.")),
                          ),
                          SizedBox(
                            height: 45,
                            child: FilledButton.tonal(
                                onPressed: handleSignup, child: const Text("Submit")),
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
                            label: const Text("Sign Up with Google")),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Footer(
                          footerMessage:
                              "${Strings.APP_NAME} is developed by A3 Group."),
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
