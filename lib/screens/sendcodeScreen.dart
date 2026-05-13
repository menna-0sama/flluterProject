import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduation/screens/resetpasswardScreen.dart';
import 'package:graduation/network/password_api.dart';

class Sendcodescreen extends StatefulWidget {
  final String email;

  const Sendcodescreen({
    super.key,
    required this.email,
  });

  @override
  State<Sendcodescreen> createState() => _SendcodescreenState();
}

class _SendcodescreenState extends State<Sendcodescreen> {
  List<String> code = ["", "", "", "", "", ""];
  int currentIndex = 0;

  int remainingTime = 60;
  Timer? timer;
  bool canResend = false;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    remainingTime = 60;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        setState(() => canResend = true);
        timer?.cancel();
      }
    });
  }

  void addDigit(String digit) {
    if (currentIndex < 6) {
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

  Future<void> verifyCode() async {
    final finalCode = code.join();

    if (finalCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full code")),
      );
      return;
    }

    setState(() => isVerifying = true);

    try {
      await PasswordApi.verifyCode(
        email: widget.email,
        code: finalCode,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Resetpasswardscreen(
            email: widget.email,
            code: finalCode,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code")),
      );
    } finally {
      if (mounted) {
        setState(() => isVerifying = false);
      }
    }
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    try {
      await PasswordApi.forgotPassword(email: widget.email);

      setState(() {
        code = ["", "", "", "", "", ""];
        currentIndex = 0;
      });

      startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code resent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to resend code")),
      );
    }
  }

  String get formattedTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget buildCodeBox({
    required int index,
    required double size,
  }) {
    return Container(
      width: size,
      height: size + 7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: currentIndex == index
              ? const Color(0xff0665BC)
              : Colors.grey,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        code[index],
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget buildRow(List<String> numbers, double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: numbers.map((n) => buildButton(n, buttonSize)).toList(),
    );
  }

  Widget buildButton(String number, double buttonSize) {
    return GestureDetector(
      onTap: () => addDigit(number),
      child: Container(
        margin: EdgeInsets.all(buttonSize * 0.12),
        width: buttonSize,
        height: buttonSize * 0.86,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final isSmall = height < 700;
    final horizontalPadding = width * 0.075;

    final titleSize = isSmall ? 26.0 : 30.0;
    final descSize = isSmall ? 14.0 : 16.0;
    final codeBoxSize = width < 380 ? 42.0 : 48.0;
    final buttonSize = width < 380 ? 58.0 : 70.0;
    final verifyHeight = isSmall ? 52.0 : 56.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmall ? 18 : 30),

                    Text(
                      "Please check your \nemail",
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: isSmall ? 14 : 20),

                    Text(
                      "We’ve sent a code to ${widget.email}",
                      style: TextStyle(
                        fontSize: descSize,
                        color: Colors.black54,
                      ),
                    ),

                    SizedBox(height: isSmall ? 28 : 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                            (index) => buildCodeBox(
                          index: index,
                          size: codeBoxSize,
                        ),
                      ),
                    ),

                    SizedBox(height: isSmall ? 28 : 50),

                    GestureDetector(
                      onTap: isVerifying ? null : verifyCode,
                      child: Container(
                        width: double.infinity,
                        height: verifyHeight,
                        decoration: BoxDecoration(
                          color: code.contains("")
                              ? Colors.grey
                              : const Color(0xff0665BC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: isVerifying
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmall ? 20 : 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: canResend ? resendCode : null,
                          child: Text(
                            "Send code again",
                            style: TextStyle(
                              fontSize: isSmall ? 14 : 16,
                              color: canResend
                                  ? const Color(0xff0665BC)
                                  : Colors.black54,
                              decoration:
                              canResend ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "($formattedTime)",
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 25 : 50),

                    Column(
                      children: [
                        buildRow(["1", "2", "3"], buttonSize),
                        buildRow(["4", "5", "6"], buttonSize),
                        buildRow(["7", "8", "9"], buttonSize),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: buttonSize),
                            buildButton("0", buttonSize),
                            IconButton(
                              onPressed: removeDigit,
                              icon: const Icon(Icons.backspace),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}