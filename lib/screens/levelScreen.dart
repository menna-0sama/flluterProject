import 'package:flutter/material.dart';
import 'package:graduation/screens/courses.dart';
import 'package:graduation/screens/chatbot.dart';

class Levelscreen extends StatefulWidget {
  const Levelscreen({super.key});

  @override
  State<Levelscreen> createState() => _LevelscreenState();
}

class _LevelscreenState extends State<Levelscreen> {
  String? selectedLevel;
  String? selectedTime;

  final List<String> levels = [
    "Junior",
    "Mid-level",
    "Senior",
    "I don't know",
  ];

  final List<String> timeOptions = [
    "1 hour",
    "2 hours",
    "3 hours",
    "4+ hours",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 🔵 الخلفية
            Container(
              width: double.infinity,
              height: 452,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/Rectangle 189.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ✨ المحتوى
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // زر Back
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // النص + الصورة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hi, Basma!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Lets get started with\n your journey",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        "images/Ilustration - Home Page.png",
                        width: 201,
                        height: 178,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // الكارد الأبيض
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
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
                        const Text(
                          "Set your goal and level",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text("How much time can you commit daily?"),
                        const SizedBox(height: 15),

                        // 🔹 كارد داخلي لكل Tracks
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 الكونتينر الأول - Track Level
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    hint: const Text("Track Level"),
                                    value: selectedLevel,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: levels.map((level) {
                                      return DropdownMenuItem<String>(
                                        value: level,
                                        child: Text(
                                          level,
                                          style: TextStyle(
                                              color: selectedLevel == level &&
                                                  level != "I don't know"
                                                  ? Colors.blue
                                                  : Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue == "I don't know") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Chatbot()),
                                        );
                                      } else {
                                        setState(() {
                                          selectedLevel = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // 🔹 الكونتينر الثاني - Set Time
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    hint: const Text("Set Time"),
                                    value: selectedTime,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: timeOptions.map((time) {
                                      return DropdownMenuItem<String>(
                                        value: time,
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                              color: selectedTime == time
                                                  ? Colors.blue
                                                  : Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedTime = newValue;
                                      });
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

                  const SizedBox(height: 40),

                  // الدائرة + المستطيل
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            "images/Reddit (1).png",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "Let me know your goal, and I’ll guide you to the right lessons",
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 🔹 زر Next → يروح لصفحة Courses
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Courses()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xff0665BC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}