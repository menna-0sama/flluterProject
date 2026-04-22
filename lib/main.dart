import 'package:flutter/material.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/screens/welcomScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 تشغيل Dio + Interceptor
  DioClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Welcomscreen(),
    );
  }
}