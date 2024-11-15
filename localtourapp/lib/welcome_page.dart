import 'package:flutter/material.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const WelcomePage({Key? key, required this.onAnimationComplete})
      : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool showCenter = false;
  bool showFinalWelcome = false;
  bool showText = false;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showCenter = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showFinalWelcome = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      showText = true;
    });

    // Call the onAnimationComplete callback after the animation finishes
    await Future.delayed(const Duration(seconds: 2));
    widget.onAnimationComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Left image animation
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: showCenter ? screenWidth / 2 - 50 : -100,
            top: screenHeight / 2 - 50,
            child: Image.asset(
              'assets/images/left.png',
              width: 100,
              height: 100,
            ),
          ),

          // Right image animation
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: showCenter ? screenWidth / 2 - 50 : screenWidth + 100,
            top: screenHeight / 2 - 50,
            child: Image.asset(
              'assets/images/right.png',
              width: 100,
              height: 100,
            ),
          ),

          // Bottom image animation
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: screenWidth / 2 - 50,
            top: showCenter ? screenHeight / 2 - 50 : screenHeight + 100,
            child: Image.asset(
              'assets/images/bottom.png',
              width: 100,
              height: 100,
            ),
          ),

          // Top image animation
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: screenWidth / 2 - 50,
            top: showCenter ? screenHeight / 2 - 50 : -100,
            child: Image.asset(
              'assets/images/top.png',
              width: 100,
              height: 100,
            ),
          ),

          // Final Welcome.png
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: showFinalWelcome ? 1.0 : 0.0,
            child: Center(
              child: Image.asset(
                'assets/images/Welcome.png',
                width: 200,
                height: 200,
              ),
            ),
          ),

          // LocalTour text animation
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: showText ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Image.asset(
                  'assets/images/LocalTour.png',
                  width: 200,
                ),
              ),
            ),
          ),

          // WelcomeTo text animation
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: showText ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Image.asset(
                  'assets/images/WelcomeTo.png',
                  width: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
