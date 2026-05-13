import 'package:flutter/material.dart';
import 'package:graduation/screens/studypage.dart';
import 'package:graduation/screens/prograss.dart';
import 'package:graduation/screens/group.dart';
import 'package:graduation/screens/profile.dart';
import 'package:graduation/screens/levelScreen.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/profile_api.dart';
import 'package:graduation/network/trak-API.dart';
import 'package:graduation/network/roadmap_api.dart';
import 'package:graduation/network/lessons_api.dart';
import 'package:graduation/model/roadmap_model.dart';
import 'package:graduation/model/lesson_model.dart';

class Courses extends StatefulWidget {
  final int trackId;
  final String level;

  const Courses({
    super.key,
    required this.trackId,
    required this.level,
  });

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  int _selectedIndex = 0;
  bool isLoading = true;

  String userName = "";
  String trackName = "frontend";
  RoadmapModel? roadmapData;

  Map<String, LessonModel> lessonsByCourseAndTitle = {};

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 18;
    if (width < 600) return 24;
    return 32;
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
    getUserData();
    loadRoadmap();
  }

  void goToLevelScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Levelscreen(
          trackId: widget.trackId,
        ),
      ),
    );
  }

  String normalizeTrackName(String name) {
    return name.toLowerCase().replaceAll("-", "").replaceAll(" ", "").trim();
  }

  String normalizeText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll("- beginner", "")
        .replaceAll("- intermediate", "")
        .replaceAll("- advanced", "")
        .replaceAll("beginner", "")
        .replaceAll("intermediate", "")
        .replaceAll("advanced", "")
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }
  String buildLessonKey({
    required String courseTitle,
    required String lessonTitle,
  }) {
    final normalizedCourse = normalizeText(courseTitle);
    final normalizedLesson = normalizeText(lessonTitle);

    return "${normalizedCourse}_$normalizedLesson";
  }
  int get totalLessons {
    if (roadmapData == null) return 0;
    return roadmapData!.roadmap.fold(
      0,
          (sum, step) => sum + step.lessons.length,
    );
  }

  LessonModel? findRealLesson({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final lessonTitle = roadmapLesson.subtopic.isEmpty
        ? roadmapLesson.topic
        : roadmapLesson.subtopic;

    final key = buildLessonKey(
      courseTitle: step.mainTopic,
      lessonTitle: lessonTitle,
    );

    return lessonsByCourseAndTitle[key];
  }

  int getRealLessonId({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final realLesson = findRealLesson(
      step: step,
      roadmapLesson: roadmapLesson,
    );

    if (realLesson != null && realLesson.id != 0) {
      return realLesson.id;
    }

    print(
      "⚠️ REAL LESSON NOT FOUND FOR COURSE: ${step.mainTopic} | LESSON: ${roadmapLesson.subtopic}",
    );

    return 0;
  }

  List<String> getLessonVideos({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final realLesson = findRealLesson(
      step: step,
      roadmapLesson: roadmapLesson,
    );

    if (realLesson != null && realLesson.videos.isNotEmpty) {
      return realLesson.videos;
    }

    return roadmapLesson.videos;
  }

  String getLessonArticle({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final realLesson = findRealLesson(
      step: step,
      roadmapLesson: roadmapLesson,
    );

    if (realLesson != null && realLesson.articleUrl.trim().isNotEmpty) {
      return realLesson.articleUrl;
    }

    return roadmapLesson.article;
  }

  String getLessonTitle({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final realLesson = findRealLesson(
      step: step,
      roadmapLesson: roadmapLesson,
    );

    return realLesson?.title ??
        (roadmapLesson.subtopic.isEmpty
            ? roadmapLesson.topic
            : roadmapLesson.subtopic);
  }

  String getLessonDescription({
    required RoadmapStepModel step,
    required RoadmapLessonModel roadmapLesson,
  }) {
    final realLesson = findRealLesson(
      step: step,
      roadmapLesson: roadmapLesson,
    );

    return realLesson?.description ?? roadmapLesson.description;
  }

  Future<void> getUserData() async {
    try {
      final profile = await ProfileApi.getProfile();
      if (!mounted) return;
      setState(() => userName = profile.firstName);
    } catch (e) {
      print("GET USER ERROR: $e");
    }
  }

  Future<void> loadRealLessonsFromCourses() async {
    try {
      final Map<String, LessonModel> tempLessons = {};

      final coursesResponse = await DioClient.dio.get(
        "/api/Courses/track/${widget.trackId}",
      );

      print("COURSES BY TRACK STATUS: ${coursesResponse.statusCode}");
      print("COURSES BY TRACK RESPONSE: ${coursesResponse.data}");

      final data = coursesResponse.data;
      List coursesJson = [];

      if (data is Map && data["data"] is List) {
        coursesJson = data["data"];
      } else if (data is List) {
        coursesJson = data;
      }

      for (final course in coursesJson) {
        if (course is Map) {
          final courseId = course["id"] ?? course["courseId"] ?? 0;
          final courseTitle =
              course["title"]?.toString() ?? course["name"]?.toString() ?? "";

          if (courseId != 0 && courseTitle.trim().isNotEmpty) {
            final lessons = await LessonsApi.getLessonsByCourse(courseId);

            for (final lesson in lessons) {
              final key = buildLessonKey(
                courseTitle: courseTitle,
                lessonTitle: lesson.title,
              );

              tempLessons[key] = lesson;

              print(
                "✅ LINKED LESSON: COURSE=$courseTitle | LESSON=${lesson.title} | ID=${lesson.id}",
              );
            }
          }
        }
      }

      lessonsByCourseAndTitle = tempLessons;

      print("REAL LESSONS LOADED: ${lessonsByCourseAndTitle.length}");
    } catch (e) {
      print("LOAD REAL LESSONS ERROR: $e");
    }
  }

  Future<void> loadRoadmap() async {
    try {
      setState(() => isLoading = true);

      final track = await TracksApi.getTrackById(widget.trackId);
      final normalizedTrack = normalizeTrackName(track?.name ?? "frontend");

      final result = await RoadmapApi.getRoadmap(
        track: normalizedTrack,
        level: widget.level,
      );

      await loadRealLessonsFromCourses();

      if (!mounted) return;

      setState(() {
        trackName = result.track.isNotEmpty ? result.track : normalizedTrack;
        roadmapData = result;
        isLoading = false;
      });
    } catch (e) {
      print("LOAD ROADMAP ERROR: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> openRoadmapLesson({
    required RoadmapStepModel step,
    required RoadmapLessonModel lesson,
  }) async {
    final lessonId = getRealLessonId(
      step: step,
      roadmapLesson: lesson,
    );

    print("🚀 OPEN LESSON ID TO STUDY PAGE: $lessonId");

    if (lessonId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lesson data is still loading, please try again"),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Studypage(
          lessonId: lessonId,
          title: getLessonTitle(
            step: step,
            roadmapLesson: lesson,
          ),
          description: getLessonDescription(
            step: step,
            roadmapLesson: lesson,
          ),
          videos: getLessonVideos(
            step: step,
            roadmapLesson: lesson,
          ),
          articleUrl: getLessonArticle(
            step: step,
            roadmapLesson: lesson,
          ),
        ),
      ),
    );

    if (result == true) {
      await loadRoadmap();
    }
  }

  Future<void> enrollAndOpenGroup() async {
    try {
      final response = await DioClient.dio.post(
        "/api/Tracks/${widget.trackId}/enroll",
      );

      print("ENROLL STATUS: ${response.statusCode}");
      print("ENROLL RESPONSE: ${response.data}");
    } catch (e) {
      print("ENROLL ERROR maybe already enrolled: $e");
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Group(trackId: widget.trackId),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Prograss(trackId: widget.trackId),
        ),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
      );
    }

    if (index == 3) {
      enrollAndOpenGroup();
    }
  }

  Widget buildTopicSection(RoadmapStepModel step) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: screenWidth(context) < 360 ? 12 : 18,
            vertical: 8,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            screenWidth(context) < 360 ? 12 : 16,
            0,
            screenWidth(context) < 360 ? 12 : 16,
            16,
          ),
          leading: CircleAvatar(
            radius: screenWidth(context) < 360 ? 18 : 20,
            backgroundColor: const Color(0xffEAF4FF),
            child: Text(
              step.step.toString(),
              style: const TextStyle(
                color: Color(0xff0088FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            step.mainTopic.isEmpty ? "Topic ${step.step}" : step.mainTopic,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: responsiveFont(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${step.lessons.length} lessons",
            style: TextStyle(
              fontSize: responsiveFont(context, 12),
              color: Colors.black54,
            ),
          ),
          children: List.generate(step.lessons.length, (index) {
            final lesson = step.lessons[index];

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => openRoadmapLesson(
                step: step,
                lesson: lesson,
              ),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(screenWidth(context) < 360 ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: screenWidth(context) < 360 ? 30 : 34,
                      height: screenWidth(context) < 360 ? 30 : 34,
                      decoration: BoxDecoration(
                        color: const Color(0xff0088FF),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.subtopic.isEmpty
                                ? lesson.topic
                                : lesson.subtopic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsiveFont(context, 14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsiveFont(context, 12),
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roadmapSteps = roadmapData?.roadmap ?? [];
    final width = screenWidth(context);

    final headerHeight = width < 360 ? 430.0 : 452.0;
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
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding(context),
                vertical: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: goToLevelScreen,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
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
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 85),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(width < 360 ? 12 : 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "images/Logo or icon.png",
                                height: width < 360 ? 30 : 35,
                                width: width < 360 ? 30 : 35,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${trackName.toUpperCase()}\nLevel: ${widget.level}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: responsiveFont(context, 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: totalLessons == 0 ? 0.05 : 0.25,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 360 ? 12 : 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trackName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: responsiveFont(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.level,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: responsiveFont(context, 12),
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 1, height: 40, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.asset(
                                "images/Logo or icon.png",
                                height: width < 360 ? 30 : 35,
                                width: width < 360 ? 30 : 35,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$trackName\n$totalLessons lessons",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: responsiveFont(context, 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: width < 360 ? 28 : 30,
                          height: width < 360 ? 28 : 30,
                          decoration: BoxDecoration(
                            color: const Color(0xff0088FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : roadmapSteps.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("No courses found"),
                    ),
                  )
                      : Column(
                    children: List.generate(roadmapSteps.length, (index) {
                      return buildTopicSection(roadmapSteps[index]);
                    }),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff0088FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: width < 360 ? 11 : 12,
        unselectedFontSize: width < 360 ? 10 : 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Group"),
        ],
      ),
    );
  }
}