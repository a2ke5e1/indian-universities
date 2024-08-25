import 'package:indian_universities/constants/Urls.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  const Footer({
    super.key,
    required this.footerMessage,
  });

  final String? footerMessage;

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  final Uri tosURL =
      Uri.parse(Urls.TOS);
  final Uri privacyPolicyURL =
      Uri.parse(Urls.PRIVACY_POLICY);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.footerMessage ?? "",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => _launchInBrowser(tosURL),
              child: const Text(
                "Terms of Service",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Padding(padding: EdgeInsets.all(4), child: Text("·")),
            InkWell(
              onTap: () => _launchInBrowser(privacyPolicyURL),
              child: const Text(
                "Privacy Policy",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
