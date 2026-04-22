import 'package:flutter/material.dart';

class Prograss extends StatelessWidget {
  const Prograss({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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

          // 🔹 المحتوى
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 back
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

                  // 🔹 الهيدر
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

                  // 🔹 main track + الدائرة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "main track",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          SizedBox(
                            width: 200,
                            child: Text(
                              "The main track provides a structured learning path to master core skills step by step.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 🔵 الدائرة
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: 0.75,
                              strokeWidth: 6,
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation(Color(0xff0088FF)),
                            ),
                          ),
                          const Text(
                            "75%",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 الكارد
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "sup course",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        const Text(
                          "Supplementary courses offer focused lessons to strengthen specific topics or skills.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),

                        const SizedBox(height: 15),

                        // 🔹 الكورسات (بعد التعديل)
                        courseItem("static", 1.0),
                        const SizedBox(height: 10),

                        courseItem("excel", 0.8),
                        const SizedBox(height: 10),

                        courseItem("Power bi", 0),
                        const SizedBox(height: 10),

                        courseItem("SQL", 0),
                        const SizedBox(height: 10),

                        courseItem("tableu", 0),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 النص تحت
                  Row(
                    children: const [
                      Text(
                        "Keep Going, You Can",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.waving_hand, color: Color(0xff0088FF), size: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 الجديد: courseItem بـ progress حقيقي
Widget courseItem(String title, double progress) {
  return Container(
    width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Stack(
      children: [
        // 🔵 الخلفية المتحركة (progress)
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff0E65B4),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        // 🔹 النص + النسبة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: progress > 0.5 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
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