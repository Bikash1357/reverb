import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reverb/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // 🌀 Animation controller for fade-in
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward(); // start animation

    // Navigation delay (for future use)
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ✅ Your preferred background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),

            // 🎵 Logo
            Center(child: Image.asset("assets/images/logo.png", height: 240)),

            SizedBox(height: 30),

            // 🔄 Loader
            CircularProgressIndicator(color: Colors.white),

            Spacer(),

            // 👇 Animated "Powered by Echoes"
            FadeTransition(
              opacity: _fadeIn,
              child: Text(
                'Powered by Echoes',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
