import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/profile_api.dart';
import 'package:graduation/screens/admin_screen.dart';
import 'package:graduation/screens/courses.dart';
import 'package:graduation/screens/welcomScreen.dart';
import 'package:graduation/screens/signupScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final token = DioClient.accessToken;

    if (token == null || token.isEmpty) {
      goTo(const Welcomscreen());
      return;
    }

    if (DioClient.isAdmin()) {
      goTo(const AdminScreen());
      return;
    }

    try {
      final profile = await ProfileApi.getProfile();

      if (profile.tracks.isNotEmpty && profile.level.isNotEmpty) {
        goTo(
          Courses(
            trackId: profile.tracks.first.id,
            level: profile.level,
          ),
        );
      } else {
        goTo(const Signupscreen());
      }
    } catch (e) {
      await DioClient.clearTokens();
      goTo(const Welcomscreen());
    }
  }

  void goTo(Widget page) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final logoSize = width < 360
        ? 210.0
        : width < 600
        ? 280.0
        : 380.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0E65B4),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              "images/image 414.png",
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}