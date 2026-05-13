import 'package:flutter/material.dart';
import 'package:graduation/model/progress_model.dart';
import 'package:graduation/network/progress_api.dart';
import 'package:graduation/network/profile_api.dart';

class Prograss extends StatefulWidget {
  final int trackId;

  const Prograss({
    super.key,
    required this.trackId,
  });

  @override
  State<Prograss> createState() => _PrograssState();
}

class _PrograssState extends State<Prograss> {
  bool isLoading = true;
  int mainProgress = 0;
  List<CourseProgressItem> courses = [];
  String userName = "";

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 18;
    if (width < 600) return 24;
    return 30;
  }

  double responsiveFont(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) return size - 2;
    if (width > 600) return size + 2;
    return size;
  }

  @override
  void initState() {
    super.initState();
    loadProgress();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final profile = await ProfileApi.getProfile();

      if (!mounted) return;

      setState(() {
        userName = profile.firstName;
      });
    } catch (e) {
      print("GET USER ERROR: $e");
    }
  }

  Future<void> loadProgress() async {
    final trackProgress = await ProgressApi.getTrackProgress(widget.trackId);
    final coursesData = await ProgressApi.getCoursesWithProgress(widget.trackId);

    if (!mounted) return;

    setState(() {
      mainProgress = trackProgress;
      courses = coursesData;
      isLoading = false;
    });
  }

  Widget buildHeader() {
    final width = screenWidth(context);

    final illustrationWidth = width < 360
        ? 145.0
        : width < 400
        ? 165.0
        : 201.0;

    final illustrationHeight = width < 360
        ? 130.0
        : width < 400
        ? 148.0
        : 178.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${userName.isEmpty ? "User" : userName}!",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFont(context, 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Lets get started with\n your journey",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: responsiveFont(context, 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          "images/Ilustration - Home Page.png",
          width: illustrationWidth,
          height: illustrationHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget buildMainTrack(double progressValue) {
    final width = screenWidth(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "main track",
                style: TextStyle(
                  fontSize: responsiveFont(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "The main track provides a structured learning path to master core skills step by step.",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsiveFont(context, 12),
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: width < 360 ? 62 : 70,
              height: width < 360 ? 62 : 70,
              child: isLoading
                  ? const CircularProgressIndicator(
                strokeWidth: 6,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(
                  Color(0xff0088FF),
                ),
              )
                  : CircularProgressIndicator(
                value: progressValue,
                strokeWidth: 6,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xff0088FF),
                ),
              ),
            ),
            Text(
              isLoading ? "..." : "$mainProgress%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsiveFont(context, 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSubCourseCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth(context) < 360 ? 12 : 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "sup course",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsiveFont(context, 14),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Supplementary courses offer focused lessons to strengthen specific topics or skills.",
            style: TextStyle(
              fontSize: responsiveFont(context, 12),
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 15),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (courses.isEmpty)
            Text(
              "No courses yet",
              style: TextStyle(
                fontSize: responsiveFont(context, 12),
                color: Colors.black54,
              ),
            )
          else
            Column(
              children: courses.map((course) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: courseItem(
                    context,
                    course.title,
                    course.progress / 100,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progressValue = mainProgress / 100;
    final width = screenWidth(context);
    final headerHeight = width < 360 ? 430.0 : 452.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Rectangle 189.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding(context),
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildHeader(),
                    const SizedBox(height: 40),
                    buildMainTrack(progressValue),
                    const SizedBox(height: 20),
                    buildSubCourseCard(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Keep Going, You Can",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsiveFont(context, 25),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.waving_hand,
                          color: Color(0xff0088FF),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget courseItem(BuildContext context, String title, double progress) {
  final width = MediaQuery.of(context).size.width;
  final fontSize = width < 360 ? 12.0 : 14.0;

  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(
      minHeight: 45,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Stack(
      children: [
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 45,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff0E65B4),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: progress > 0.5 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  color: progress > 0.5 ? Colors.white : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}