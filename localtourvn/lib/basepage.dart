import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;

  const BasePage({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  late ScrollController _scrollController;
  bool _showBackToTopButton = false;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        // Show the back-to-top button only when the user has scrolled down 200 pixels
        if (_scrollController.offset >= 200) {
          _showBackToTopButton = true;
        } else {
          _showBackToTopButton = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Method to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  // Method to toggle the form visibility
  void _toggleFormVisibility() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  // Close the form when tapping outside
  void _closeForm() {
    if (_showForm) {
      setState(() {
        _showForm = false;
      });
    }
  }

  // Navigate to HistoryPage
  void _navigateToHistoryPage() {
    Navigator.pushNamed(context, '/history'); // Use named route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Close the form when user taps outside
          _closeForm();
        },
        child: Stack(
          children: [
            // The main body content with a ScrollController
            SingleChildScrollView(
              controller: _scrollController,
              child: widget.body,
            ),
            // "Back to Top" button at the bottom center
            if (_showBackToTopButton)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _scrollToTop,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text("Back to Top"),
                  ),
                ),
              ),
            // Three vertical segments button at the bottom left
            Positioned(
              bottom: 0,
              left: 25,
              child: IconButton(
                onPressed: _toggleFormVisibility,
                icon: const Icon(Icons.more_vert),
              ),
            ),
            // Show the form when the vertical segments button is clicked
            if (_showForm)
              Positioned(
                bottom: 50, // Position above the floating action button
                left: 40,
                child: GestureDetector(
                  onTap: () {
                    // Prevent the GestureDetector from closing the form when tapping inside the form
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36), // Add border radius
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 2, // Border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 3, // Shadow blur
                          offset: const Offset(10, -10), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: _navigateToHistoryPage, // Navigate to HistoryPage
                          icon: const Icon(Icons.history),
                        ),
                        IconButton(
                          onPressed: () {
                            // Handle weather icon tap
                          },
                          icon: const Icon(Icons.wb_sunny),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      // Bottom Navigation Bar with Border
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black, // Border color
              width: 2.0,         // Border width
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTabTapped,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
            BottomNavigationBarItem(icon: Icon(Icons.map_sharp), label: 'Map',),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'BookMark',),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Schedule',),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Account',),
          ],
        ),
      ),
    );
  }
}
