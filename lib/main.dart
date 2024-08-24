import 'package:flutter/material.dart';
import 'package:indian_universities/auth/signup.dart';
import 'package:indian_universities/models/user.dart';
import 'package:indian_universities/pages/home.dart';
import 'package:indian_universities/pages/reset_password.dart';
import 'package:indian_universities/pages/wrapper.dart';
import 'package:indian_universities/services/auth.dart';
import 'auth/signIn.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:indian_universities/pages/universityDetails.dart';
import 'package:provider/provider.dart';
import 'package:indian_universities/auth/authenticate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _lightscheme = ColorScheme.fromSeed(seedColor: Colors.blue);
  static final _darkscheme =
      ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
        value: AuthService().user,
        initialData: null,
        child: DynamicColorBuilder(builder:
            (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
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
              '/': (context) => const Wrapper(),
              '/details': (context) => const SearchUni(),
              '/signup': (context) => const SignUpPage(),
              '/signin': (context) => const SignInPage(),
              '/auth': (context) => const Authenticate(),
              '/home': (context) => const Home(),
              "/reset": (context) => const ResetPasswordScreen(),
            },
          );
        }));
  }
}
