import 'package:indian_universities/models/user.dart';
import 'package:indian_universities/auth/authenticate.dart';
import 'package:indian_universities/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    print(user);
    //return either auth or home widget
    if (user == null) {
      return const Authenticate();
    } else {
      return const Home();
    }
  }
}
