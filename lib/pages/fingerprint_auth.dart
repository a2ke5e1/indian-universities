import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:indian_universities/pages/home.dart';

class fingerprint extends StatefulWidget {
  const fingerprint({super.key});

  @override
  State<fingerprint> createState() => _fingerprintState();
}

class _fingerprintState extends State<fingerprint> {
  late final LocalAuthentication auth;
  bool? didAuthenticate = false;
  Future getuser() async {
    try {
      didAuthenticate = await auth
          .authenticate(
              localizedReason: 'Please authenticate to use App',
              options: const AuthenticationOptions(biometricOnly: true))
          .then((_) {
        (bool isAuth) => setState(() {
              didAuthenticate = isAuth;
            });
        return null;
      });
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/home", (route) => false, arguments: {
        "didAuthenticate": didAuthenticate,
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<List<BiometricType>> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    print(availableBiometrics);
    return availableBiometrics;
  }

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getuser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return didAuthenticate!
        ? const Home()
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Please Authenticate to use App",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      getuser();
                    },
                    child: const Text("Authenticate"),
                  ),
                ],
              ),
            ),
          );
  }
}
