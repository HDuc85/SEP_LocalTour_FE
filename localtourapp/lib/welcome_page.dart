import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const WelcomePage({Key? key, required this.onAnimationComplete})
      : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  bool showWelcomeTo = false; // For WelcomeTo.png
  bool showLocalTour = false; // For LocalTour.png
  bool showWelcome = false; // For Welcome.png

  late AnimationController _controller;

  // Animations for positions
  late Animation<double> leftAnimation;
  late Animation<double> rightAnimation;
  late Animation<double> topAnimation;
  late Animation<double> bottomAnimation;

  // Flags to control visibility and initialization
  bool showLeftImage = true;
  bool showRightImage = true;
  bool showTopImage = true;
  bool showBottomImage = true;

  bool showFinalWelcome = false;
  bool showText = false;

  bool isInitialized = false; // Flag to check if animations are initialized

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust as needed
    );

    // Start the animation sequence after a delay
    _startDelayedAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      // Initialize animations using MediaQuery safely
      _initAnimations();
      isInitialized = true;
    }
  }

  void _initAnimations() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // Calculate positions
    double leftImageStartX = -100; // Off-screen to the left
    double leftImageEndX = centerX - 100; // Left edge of Welcome.png

    double rightImageStartX = screenWidth + 100; // Off-screen to the right
    double rightImageEndX = centerX + 100; // Right edge of Welcome.png

    double topImageStartY = -100; // Off-screen at the top
    double topImageEndY = centerY - 100; // Top edge of Welcome.png

    double bottomImageStartY = screenHeight + 100; // Off-screen at the bottom
    double bottomImageEndY = centerY + 100; // Bottom edge of Welcome.png

    // Initialize animations
    leftAnimation = Tween<double>(
      begin: leftImageStartX,
      end: leftImageEndX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    rightAnimation = Tween<double>(
      begin: rightImageStartX,
      end: rightImageEndX - 100, // Subtract image width
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    topAnimation = Tween<double>(
      begin: topImageStartY,
      end: topImageEndY,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    bottomAnimation = Tween<double>(
      begin: bottomImageStartY,
      end: bottomImageEndY - 100, // Subtract image height
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
  }

  Future<void> _startDelayedAnimation() async {
    // Add a delay before starting the animation
    await Future.delayed(const Duration(seconds: 2));

    // Start the animation
    _controller.forward();

    // Add a listener to control visibility
    _controller.addListener(() {
      setState(() {
        if (_controller.value >= 0.5) {
          showLeftImage = false;
          showRightImage = false;
          showTopImage = false;
          showBottomImage = false;

          if (!showFinalWelcome) {
            showFinalWelcome = true;
          }
        }
      });
    });

    // When animation completes, start showing images gradually
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Make WelcomeTo.png appear gradually
        setState(() {
          showWelcomeTo = true;
        });
        await Future.delayed(const Duration(seconds: 1));

        // Make LocalTour.png appear gradually
        setState(() {
          showLocalTour = true;
        });
        await Future.delayed(const Duration(seconds: 1));

        // Make Welcome.png appear gradually
        setState(() {
          showWelcome = true;
        });
        await Future.delayed(const Duration(seconds: 2));

        // Call the animation complete callback
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          if (isInitialized && showLeftImage)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: leftAnimation.value,
                  top: MediaQuery.of(context).size.height / 2 - 50,
                  child: Image.asset(
                    'assets/images/left.png',
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),

          // Right image animation
          if (isInitialized && showRightImage)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: rightAnimation.value,
                  top: MediaQuery.of(context).size.height / 2 - 50,
                  child: Image.asset(
                    'assets/images/right.png',
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),

          // Top image animation
          if (isInitialized && showTopImage)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  top: topAnimation.value,
                  child: Image.asset(
                    'assets/images/top.png',
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),

          // Bottom image animation
          if (isInitialized && showBottomImage)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  top: bottomAnimation.value,
                  child: Image.asset(
                    'assets/images/bottom.png',
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),

          // Final Welcome.png
          if (showFinalWelcome)
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: showWelcome ? 1.0 : 0.0,
              child: Center(
                child: Image.asset(
                  'assets/images/Welcome.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),

// WelcomeTo.png
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: showWelcomeTo ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Image.asset(
                  'assets/images/WelcomeTo.png',
                  width: 200,
                ),
              ),
            ),
          ),

// LocalTour text animation
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: showLocalTour ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Image.asset(
                  'assets/images/LocalTour.png',
                  width: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


