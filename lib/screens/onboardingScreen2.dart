import 'package:flutter/material.dart';
import 'onboardingScreen.dart';
import 'onboardingScreen3.dart';

class Onboardingscreen2 extends StatelessWidget {
  const Onboardingscreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // أشكال في الخلفية
            Positioned(
              top: 50,
              left: 30,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 150,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.pink.shade400,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // المحتوى الرئيسي
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "images/Image 3.png",
                  width: 300,
                  height: 236,
                ),
                const SizedBox(height: 60),
                const Text(
                  'Learn by Doing',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Write real code and practice with live challenges.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            // زرار الرجوع للصفحة السابقة
            Positioned(
              bottom: 50,
              left: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // يرجع للصفحة السابقة (Onboarding1)
                },
                style: ElevatedButton.styleFrom(

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),

            // زرار الذهاب للصفحة التالية
            Positioned(
              bottom: 50,
              right: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Onboardingscreen3(), // أو الصفحة النهائية
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E65B4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),

          ],
        ),
      ),
    );
  }
}