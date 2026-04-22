import 'package:flutter/material.dart';
import 'package:graduation/screens/signupScreen.dart';

class Passwordchangescreen extends StatelessWidget {
  const Passwordchangescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // عشان يجي النص والزرار في النص
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Password changed",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Your password has been changed \nsuccessfully",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Signupscreen(), // 👈 هنا شاشة الـ Login
                  ),
                      (route) => false, // يمسح كل الصفحات السابقة
                );
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xff0665BC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Back to Login",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}