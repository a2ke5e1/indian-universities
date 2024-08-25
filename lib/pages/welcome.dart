import 'package:indian_universities/constants/Strings.dart';
import 'package:indian_universities/constants/Urls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      Navigator.of(context).pushReplacementNamed("/home");
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  final Uri tosURL = Uri.parse(Urls.TOS);
  final Uri privacyPolicyURL = Uri.parse(Urls.PRIVACY_POLICY);

  @override
  void initState() {
    checkFirstSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 48, right: 48, bottom: 64, top: 64),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        Strings.APP_NAME,
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        Strings.APP_SLOGAN_NAME,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.school_rounded,
                  size: 200,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Column(children: [
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "You can read our ",
                            style: themeData.textTheme.bodyMedium),
                        TextSpan(
                          text: "Terms and Condition",
                          style: themeData.textTheme.bodyMedium!.copyWith(
                            color: themeData.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                              _launchInBrowser(tosURL);
                            },
                        ),
                        TextSpan(
                            text: " and ",
                            style: themeData.textTheme.bodyMedium),
                        TextSpan(
                          text: "Privacy Policy.",
                          style: themeData.textTheme.bodyMedium!.copyWith(
                            color: themeData.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                              _launchInBrowser(privacyPolicyURL);
                            },
                        ),
                      ])),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('seen', true);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text("Next"),
                  ),
                ])
              ]),
        ),
      ),
    );
  }
}
