import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kerbros/screens/loginPage.dart';
import 'package:kerbros/screens/register.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,
            "assets/img_3.png",
            fit: BoxFit.cover, // Cover the whole screen
          ),
          // Black shadow overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
            ),
          ),
          // Centered text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to', // Your text here
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // Space between the two texts
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32, // Font size for KERBROS
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    children: [
                      TextSpan(
                        text: 'K',
                        style: TextStyle(color: Colors.red),
                      ),
                      TextSpan(
                        text: 'E',
                        style: TextStyle(color: Colors.orange),
                      ),
                      TextSpan(
                        text: 'R',
                        style: TextStyle(color: Colors.yellow),
                      ),
                      TextSpan(
                        text: 'B',
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: 'R',
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextSpan(
                        text: 'O',
                        style: TextStyle(color: Colors.indigo),
                      ),
                      TextSpan(
                        text: 'S',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
