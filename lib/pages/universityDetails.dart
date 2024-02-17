import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class SearchUni extends StatefulWidget {
  const SearchUni({super.key});

  @override
  State<SearchUni> createState() => _SearchUniState();
}

class _SearchUniState extends State<SearchUni> {
  ScreenshotController screenshotController = ScreenshotController();

  GlobalKey previewContainer = GlobalKey();
  int originalSize = 800;

  void handleShareButton() async {
    screenshotController.capture().then((Uint8List? value) async {
      // make a XFile from the bytes
      final path = await storeFileTemporarily(value!);
      await Share.shareXFiles(
        [XFile(path)],
      );
    });
  }

  Future<String> storeFileTemporarily(Uint8List image) async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/test.png';
    final file = await File(path).create();
    file.writeAsBytesSync(image);

    return path;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      if (url.startsWith("https://")) {
        await launch(url);
      } else if (url.startsWith("http://")) {
        await launch(url);
      }
    } else {
      await launch("https://$url");
    }
  }

  Map data = {};

  @override
  void initState() {
    super.initState();
    print("Home page ... ");
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        appBar: AppBar(
          title: data['University_Name'] != null
              ? Text(
                  data['University_Name'],
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : const Text(""),
          elevation: 0.0,
        ),
        body: Container(
          // margin: EdgeInsets.only(top: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "University ID",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(data['University_Id'],
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "University Name",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(data['University_Name'],
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: const Text("University Type")),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(data['University_Type'],
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "State",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(data['State'],
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: const Text(
                        "Address",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(data['Address'],
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Website",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: InkWell(
                        onTap: () => _launchURL(data['Website']),
                        child: Text(
                          data['Website'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: !kIsWeb
            ? FloatingActionButton(
                onPressed: handleShareButton,
                key: const Key('share'),
                child: const Icon(Icons.share),
              )
            : null);
  }
}
