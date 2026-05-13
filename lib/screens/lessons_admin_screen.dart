import 'package:flutter/material.dart';

class LessonsAdminScreen extends StatelessWidget {
  final int courseId;
  final String courseTitle;

  const LessonsAdminScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lessons - $courseTitle"),
      ),
      body: Center(
        child: Text("Course ID: $courseId"),
      ),
    );
  }
}