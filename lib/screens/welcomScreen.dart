import 'package:flutter/material.dart';
import 'onboardingScreen.dart';

class Welcomscreen extends StatelessWidget {
  const Welcomscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingPage1(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Color(0xFF0E65B4),
        body: Center(
          child: Image.asset(
            "images/image 414.png",
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }
}