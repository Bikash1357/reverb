import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reverb/screens/gender_screen.dart';
import 'package:reverb/screens/height_screen.dart';
import 'package:reverb/screens/signup_screen.dart';
import 'package:reverb/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
//import 'screens/splash_screen.dart'; // splash screen import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ReverbApp());
}

class ReverbApp extends StatelessWidget {
  const ReverbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reverb',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: SplashScreen(), // first screen
    );
  }
}
