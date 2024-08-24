import 'package:indian_universities/constants/Strings.dart';
import 'package:indian_universities/constants/Urls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About {

  final BuildContext context;

  About(this.context);

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


  void showCustomDialogBox() async {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
    MaterialLocalizations.of(context);
    const double _textVerticalSeparation = 18.0;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: ListBody(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      child: Icon(Icons.visibility,
                          size: 50, color: themeData.colorScheme.primary),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: ListBody(
                          children: <Widget>[
                            Text(Strings.APP_NAME,
                                style: themeData.textTheme.headlineSmall),
                            Text(Strings.APP_VERSION,
                                style: themeData.textTheme.bodyMedium),
                            const SizedBox(height: _textVerticalSeparation),
                            Text('Developed by ${Strings.APP_ORG}\n\n',
                                style: themeData.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                    Strings.ABOUT_APP_DESCRIPTION
                ),
                const SizedBox(height: 12),
                Text("Join our community",
                    style: themeData.textTheme.bodyMedium),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.pop(context);
                          _launchInBrowser(Uri.parse(Urls.TELEGRAM));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Icon(
                              Icons.telegram_outlined,
                              color: themeData.colorScheme.onPrimaryContainer
                          ),
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.pop(context);
                          Share.share(
                            Strings.ABOUT_SHARE_DESCRIPTION,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Icon(
                              Icons.share_outlined,
                              color: themeData.colorScheme.onPrimaryContainer
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
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
                          text: " and ", style: themeData.textTheme.bodyMedium),
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
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(themeData.useMaterial3
                    ? localizations.closeButtonLabel
                    : localizations.closeButtonLabel.toUpperCase()),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            scrollable: true,
          );
        });
  }

}