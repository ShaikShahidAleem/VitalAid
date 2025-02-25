import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'welcome_page.dart';
import 'email_verification_screen.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

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
          // User is signed in, check if email is verified
          final user = FirebaseAuth.instance.currentUser!;
          
          if (user.emailVerified) {
            // Email is verified, redirect to HomePage
            return HomePage();
          } else {
            // Email is not verified, redirect to EmailVerificationScreen
            return EmailVerificationScreen();
          }
        } else {
          // User is not signed in, redirect to WelcomePage
          return const WelcomePage();
        }
      },
    );
  }
}
