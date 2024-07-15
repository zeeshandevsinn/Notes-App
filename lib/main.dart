import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_app/firebase_options.dart';
import 'package:note_app/screens/home.dart';
import 'package:note_app/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator if connection state is waiting
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasData && snapshot.data is User) {
              // User is logged in, navigate to HomeScreen
              return const HomeScreen();
            } else {
              // User is not logged in, navigate to LoginScreen
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}
