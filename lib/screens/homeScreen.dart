import 'package:flutter/material.dart';
import 'package:graduation/screens/levelScreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool _isPressed1 = false;
  bool _isPressed2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // 🔵 الخلفية تغطي كامل الشاشة
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

          // ✨ محتوى الشاشة فوق الخلفية
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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
                      children: const [
                        Text(
                          "Choose your track",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("Ready to Craft Your Code? let's start"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔹 الكارد الداخلي للقناتين مع تأثير الضغط
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        // 🔹 الكونتينر الأول
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isPressed1 = true),
                          onTapUp: (_) => setState(() => _isPressed1 = false),
                          onTapCancel: () => setState(() => _isPressed1 = false),
                          onTap: () {
                            // هنا ممكن تضيفي وظيفة الضغط
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            transform: _isPressed1
                                ? (Matrix4.identity()..scale(0.97))
                                : Matrix4.identity(),
                            curve: Curves.easeOut,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: _isPressed1 ? 2 : 5,
                                  offset: Offset(0, _isPressed1 ? 2 : 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: const [
                                Image(
                                  image: AssetImage("images/Rectangle 257.png"),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "UI Design",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Learn the basics of user interface design and improve your UX skills.",
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🔹 الكونتينر الثاني
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isPressed2 = true),
                          onTapUp: (_) => setState(() => _isPressed2 = false),
                          onTapCancel: () => setState(() => _isPressed2 = false),
                          onTap: () {
                            // هنا ممكن تضيفي وظيفة الضغط
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            transform: _isPressed2
                                ? (Matrix4.identity()..scale(0.97))
                                : Matrix4.identity(),
                            curve: Curves.easeOut,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: _isPressed2 ? 2 : 5,
                                  offset: Offset(0, _isPressed2 ? 2 : 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: const [
                                Image(
                                  image: AssetImage("images/Rectangle 257 (1).png"),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Flutter",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Start building apps using Flutter and understand the core concepts quickly.",
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
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
                        height:60,
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

                  const SizedBox(height: 20),

                  // 🔹 زر Next → يروح لصفحة Levelscreen
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Levelscreen()),
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}