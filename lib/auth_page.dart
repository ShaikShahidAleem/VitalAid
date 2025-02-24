import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'welcome_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for auth state
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in, redirect to HomePage
          return HomePage();
        } else {
          // User is not signed in, redirect to WelcomePage
          return const WelcomePage();
        }
      },
    );
  }
}
