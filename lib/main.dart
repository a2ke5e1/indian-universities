import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indian_universities/auth/signin.dart';
import 'package:indian_universities/auth/signup.dart';
import 'package:indian_universities/pages/home.dart';
import 'package:indian_universities/pages/reset_password.dart';
import 'package:indian_universities/pages/universityDetails.dart';
import 'package:indian_universities/pages/welcome.dart';
import 'package:indian_universities/services/auth_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _lightscheme = ColorScheme.fromSeed(seedColor: Colors.blue);
  static final _darkscheme =
      ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return DynamicColorBuilder(
        builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
      return MaterialApp(
        title: 'Uni-App',
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _lightscheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _darkscheme,
          useMaterial3: true,
        ),
        initialRoute: "/",
        routes: {
          '/': (context) => const WelcomePage(),
          '/details': (context) => const SearchUni(),
          '/signup': (context) => const SignUpPage(),
          '/signin': (context) => const SignInPage(),
          '/home': (context) => const Home(),
          "/reset": (context) => const ResetPasswordScreen(),
        },
      );
    });
  }
}
