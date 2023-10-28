import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/Strings.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResend = true;
  Timer? resendTimer;
  int resendTime = 60;
  Timer? countDownTimer;

  @override
  void initState() {
    super.initState();

    sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkEmailVerified();
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

  /// This function is used to check if the email is verified or not.
  /// If the email is verified then the user is redirected to the home page
  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Successfully Verified")));
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      timer?.cancel();
    }
  }

  /// This function is used to send the email verification link to the user
  sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    //  print("Sending Email Verification...");
    setState(() {
      canResend = false;
      resendTime = 60;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    countDownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          scrolledUnderElevation: 0,
          centerTitle: true,
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
                          "Email Verification",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 40),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          Strings.EMAIL_VERIFICATION_INTRO,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                        'Check your Email, We have sent you a Email on  ${FirebaseAuth.instance.currentUser?.email}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                    const SizedBox(height: 80),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifying email....',
                    ),
                    const SizedBox(height: 57),
                    Text(
                      'You can resend the email after $resendTime seconds',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: canResend
                            ? () {
                                sendEmailVerification();
                              }
                            : null,
                        child: const Text('Resend'),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(""),
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
