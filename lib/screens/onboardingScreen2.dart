import 'package:flutter/material.dart';
import 'onboardingScreen3.dart';

class Onboardingscreen2 extends StatefulWidget {
  const Onboardingscreen2({super.key});

  @override
  State<Onboardingscreen2> createState() => _Onboardingscreen2State();
}

class _Onboardingscreen2State extends State<Onboardingscreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _imageSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget animatedCircle(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isSmall = height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: height * 0.06,
              left: width * 0.07,
              child: animatedCircle(
                Container(
                  width: isSmall ? 30 : 40,
                  height: isSmall ? 30 : 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Positioned(
              top: height * 0.10,
              left: width * 0.35,
              child: animatedCircle(
                Container(
                  width: isSmall ? 30 : 40,
                  height: isSmall ? 30 : 40,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Positioned(
              top: height * 0.03,
              right: width * 0.08,
              child: animatedCircle(
                Container(
                  width: isSmall ? 45 : 60,
                  height: isSmall ? 45 : 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.08,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.05),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _imageSlideAnimation,
                          child: Image.asset(
                            "images/Image 3.png",
                            width: width * 0.70,
                            height: height * 0.30,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.05),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Text(
                            'Learn by Doing',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmall ? 26 : 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                            ),
                            child: Text(
                              'Write real code and practice with live challenges.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 16 : 20,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.12),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: height * 0.05,
              left: width * 0.08,
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 18 : 20,
                        vertical: isSmall ? 13 : 15,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: isSmall ? 22 : 25,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: height * 0.05,
              right: width * 0.08,
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboardingscreen3(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E65B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 18 : 20,
                        vertical: isSmall ? 13 : 15,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: isSmall ? 22 : 25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}