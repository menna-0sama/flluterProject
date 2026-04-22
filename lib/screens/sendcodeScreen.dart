import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduation/screens/resetpasswardscreen.dart';

class Sendcodescreen extends StatefulWidget {
  const Sendcodescreen({super.key});

  @override
  State<Sendcodescreen> createState() => _SendcodescreenState();
}

class _SendcodescreenState extends State<Sendcodescreen> {
  List<String> code = ["", "", "", ""];
  int currentIndex = 0;

  // Timer
  int remainingTime = 20;
  Timer? timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    remainingTime = 20;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
        debugPrint("Remaining time: $remainingTime"); // لتأكيد العداد
      } else {
        setState(() {
          canResend = true;
        });
        timer?.cancel();
      }
    });
  }

  void addDigit(String digit) {
    if (currentIndex < 4) {
      setState(() {
        code[currentIndex] = digit;
        currentIndex++;
      });
    }
  }

  void removeDigit() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        code[currentIndex] = "";
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Please check your \nemail",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "We’ve sent a code to helloworld@gmail.com",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 50),

            // مربعات الكود
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Container(
                  width: 70,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: currentIndex == index
                          ? Color(0xff0665BC)
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    code[index],
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }),
            ),
            SizedBox(height: 50),

            // زرار Verify
            GestureDetector(
              onTap: () {
                String finalCode = code.join();
                if (finalCode.length == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Resetpasswardscreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter the full code")),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: code.contains("") ? Colors.grey : Color(0xff0665BC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Verify",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // النص والعداد جنب بعض داخل Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: canResend
                      ? () {
                    startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Code resent!")),
                    );
                  }
                      : null,
                  child: Text(
                    "Send code again",
                    style: TextStyle(
                      fontSize: 16,
                      color: canResend ? Color(0xff0665BC) : Colors.black54,
                      decoration: canResend ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "(${remainingTime.toString().padLeft(2, '0')})",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),

            SizedBox(height: 50), // بدل Spacer عشان العداد يشتغل صح

            // الكيبورد
            Column(
              children: [
                buildRow(["1", "2", "3"]),
                buildRow(["4", "5", "6"]),
                buildRow(["7", "8", "9"]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: 60),
                    buildButton("0"),
                    IconButton(
                      onPressed: removeDigit,
                      icon: Icon(Icons.backspace),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: numbers.map((n) => buildButton(n)).toList(),
    );
  }

  Widget buildButton(String number) {
    return GestureDetector(
      onTap: () => addDigit(number),
      child: Container(
        margin: EdgeInsets.all(10),
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}