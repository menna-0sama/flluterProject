import 'package:flutter/material.dart';
import 'package:graduation/screens/courses.dart';
import 'package:graduation/screens/chatbot.dart';
import 'package:graduation/screens/homeScreen.dart';
import 'package:graduation/model/level_request_model.dart';
import 'package:graduation/network/level_api.dart';
import 'package:graduation/network/profile_api.dart';

class Levelscreen extends StatefulWidget {
  final int trackId;

  const Levelscreen({super.key, required this.trackId});

  @override
  State<Levelscreen> createState() => _LevelscreenState();
}

class _LevelscreenState extends State<Levelscreen> {
  String? selectedLevel;
  bool isLoading = false;
  String userName = "";

  final List<String> levels = [
    "beginner",
    "intermediate",
    "advanced",
    "I don't know",
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void goBack() {
    if (selectedLevel != null && selectedLevel!.trim().isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Courses(
            trackId: widget.trackId,
            level: selectedLevel!,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
      );
    }
  }

  Future<void> getUserData() async {
    try {
      final profile = await ProfileApi.getProfile();
      if (!mounted) return;

      setState(() {
        userName = profile.firstName;

        if (profile.level.trim().isNotEmpty &&
            levels.contains(profile.level.trim().toLowerCase())) {
          selectedLevel = profile.level.trim().toLowerCase();
        }
      });
    } catch (e) {
      print("GET USER ERROR: $e");
    }
  }

  Future<void> handleNext() async {
    if (selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select level")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final model = LevelRequestModel(
        trackId: widget.trackId,
        level: selectedLevel!,
        time: "",
      );

      await LevelApi.setLevel(model);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Courses(
            trackId: widget.trackId,
            level: selectedLevel!,
          ),
        ),
      );
    } catch (e) {
      print("SET LEVEL ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save level")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final isSmall = height < 700;
    final horizontalPadding = width * 0.075;
    final topPadding = isSmall ? 40.0 : 60.0;
    final headerImageWidth = isSmall ? width * 0.38 : width * 0.48;
    final headerImageHeight = isSmall ? height * 0.17 : height * 0.22;
    final backgroundHeight = isSmall ? height * 0.46 : height * 0.50;

    return Scaffold(
      backgroundColor: const Color(0xFFffffFF),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox(
            width: width,
            height: backgroundHeight,
            child: Image.asset(
              "images/Rectangle 189.png",
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: topPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: goBack,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: isSmall ? 14 : 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi, ${userName.isEmpty ? "User" : userName}!",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmall ? 20 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Lets get started with\n your journey",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isSmall ? 14 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "images/Ilustration - Home Page.png",
                              width: headerImageWidth,
                              height: headerImageHeight,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        SizedBox(height: isSmall ? 25 : 40),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmall ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Set your goal and level",
                                style: TextStyle(
                                  fontSize: isSmall ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Choose your current level",
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14,
                                ),
                              ),
                              SizedBox(height: isSmall ? 12 : 15),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isSmall ? 10 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      height: isSmall ? 54 : 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          hint: const Text("Track Level"),
                                          value: selectedLevel,
                                          isExpanded: true,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          items: levels.map((level) {
                                            return DropdownMenuItem(
                                              value: level,
                                              child: Text(
                                                level,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value == "I don't know") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Chatbot(
                                                    trackId: widget.trackId,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              setState(() {
                                                selectedLevel = value;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmall ? 25 : 40),
                        GestureDetector(
                          onTap: isLoading ? null : handleNext,
                          child: Container(
                            width: double.infinity,
                            height: isSmall ? 52 : 56,
                            decoration: BoxDecoration(
                              color: const Color(0xff0665BC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}