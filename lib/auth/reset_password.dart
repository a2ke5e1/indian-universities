import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:indian_universities/components/about.dart';
import 'package:indian_universities/constants/Strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/footer.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final _resetEmailFormKey = GlobalKey<FormState>();
  bool wrongEmailPassword = false;

  /// resendTimer and canResend are used to check if the user can resend the email or not
  bool firstTime = true;
  bool canResend = true;
  Timer? resendTimer;
  String? errorMessage;

  /// countDownTimer and resendTime are used to show the time left to resend the email
  int resendTime = 60;
  Timer? countDownTimer;

  @override
  void initState() {
    super.initState();

    /// add a on text change listener to the email field
    /// to remove the error message when the user starts typing

    emailController.addListener(() {
      if (wrongEmailPassword) {
        setState(() {
          wrongEmailPassword = false;
        });
      }
    });

    resendTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        canResend = true;
      });
    });

    countDownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (resendTime > 0) {
          resendTime--;
        }
      });
    });
  }

  /// This function is used to send the email verification link to the user
  sendResetPasswordEmail() async {
    if (_resetEmailFormKey.currentState!.validate()) {
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
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.toString());

        setState(() {
          firstTime = false;
          canResend = false;
          resendTime = 60;
        });

        SnackBar snackBar = const SnackBar(
          content: Text('Email sent successfully'),
          duration: Duration(seconds: 3),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            errorMessage = 'No user found for that email.';
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            errorMessage = 'Wrong password provided for that user.';
          });
        }
        setState(() {
          wrongEmailPassword = true;
        });
      } on Exception catch (e) {
        setState(() {
          errorMessage = e.toString();
          wrongEmailPassword = true;
        });
      }

      Navigator.of(context).pop();
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
  void dispose() {
    resendTimer?.cancel();
    countDownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        Strings.RESET_PASSWORD_DESCRIPTION,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  wrongEmailPassword
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(errorMessage == null ? '' : errorMessage!,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  Form(
                      key: _resetEmailFormKey,
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
                            border: OutlineInputBorder(), labelText: 'Email'),
                      )),
                  const SizedBox(height: 20),
                  Text(
                    firstTime
                        ? ''
                        : 'You can resend the email after $resendTime seconds',
                  ),
                  SizedBox(height: canResend ? 0 : 8),
                  SizedBox(
                    height: 45,
                    child: FilledButton.tonal(
                      onPressed: canResend
                          ? () {
                              sendResetPasswordEmail();
                            }
                          : null,
                      child:
                          firstTime ? const Text('Send') : const Text('Resend'),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                   const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Footer(footerMessage: "Eye Care is developed by A3 Group."),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
