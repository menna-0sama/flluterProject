import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation/network/email_verification_api.dart';
import 'package:graduation/screens/signupScreen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> verifyEmail() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      showMessage("Please enter verification code");
      return;
    }

    if (code.length != 6) {
      showMessage("Verification code must be 6 digits");
      return;
    }

    try {
      setState(() => isLoading = true);

      final result = await EmailVerificationApi().verifyEmail(
        email: widget.email,
        code: code,
      );

      print("VERIFY EMAIL RESULT: $result");

      if (!mounted) return;

      showMessage("Email verified successfully");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Signupscreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      print("VERIFY EMAIL ERROR: $e");

      showMessage("Invalid verification code");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isSmall = height < 700;
    final horizontalPadding = width < 360 ? 20.0 : width * 0.075;
    final topSpace = isSmall ? height * 0.07 : height * 0.10;
    final titleSize = isSmall ? 27.0 : 32.0;
    final cardPadding = width < 360 ? 18.0 : 22.0;
    final iconSize = width < 360 ? 72.0 : 86.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF7F9FC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0E65B4),
                      Color(0xffF7F9FC),
                    ],
                    stops: [0.0, 0.28],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: topSpace),

                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xff0665BC),
                          size: 44,
                        ),
                      ),

                      SizedBox(height: isSmall ? 24 : 34),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Verify Email",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "We sent a 6-digit code to",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 13 : 14,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              widget.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 13 : 14,
                                color: const Color(0xff0665BC),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: isSmall ? 24 : 30),

                            TextFormField(
                              controller: codeController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: TextStyle(
                                fontSize: isSmall ? 22 : 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "000000",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  letterSpacing: 8,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: isSmall ? 14 : 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xff0665BC),
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xffF7F9FC),
                              ),
                            ),

                            SizedBox(height: isSmall ? 22 : 28),

                            GestureDetector(
                              onTap: isLoading ? null : verifyEmail,
                              child: Container(
                                width: double.infinity,
                                height: isSmall ? 50 : 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xff0665BC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : Text(
                                    "Verify",
                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  color: Color(0xff0665BC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}