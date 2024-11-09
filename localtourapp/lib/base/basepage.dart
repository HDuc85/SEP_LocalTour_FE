import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isMapPage;
  final ScrollController? scrollController;

  const BasePage({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.isMapPage = false,
    this.scrollController,
  });

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
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset >= 200) {
          _showBackToTopButton = true;
        }
      });
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void _closeForm() {
    if (_showForm) {
      setState(() {
        _showForm = false;
      });
    }
  }

  void _navigateToWeatherPage() {
    // Ensure navigation is not triggered during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/weather');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _closeForm,
        child: Stack(
          children: [
            // The main body content
            widget.isMapPage
                ? widget.body
                : SingleChildScrollView(
              controller: _scrollController,

                child: widget.body,
            ),
            // Back to Top button (visible when scrolled)
            if (_showBackToTopButton && !widget.isMapPage)
              Positioned(
                bottom: 5, // Adjusted to avoid overlapping with bottom navigation
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _scrollToTop,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text("Back to Top", style: TextStyle(color: Colors.black),),
                  ),
                ),
              ),
            // Weather button at the bottom left
            if (!widget.isMapPage)
              Positioned(
                bottom: 5, // Adjusted position for better placement
                left: 20,
                child: IconButton(
                  onPressed: _navigateToWeatherPage,
                  icon: Image.asset(
                    'assets/icons/weather.png',
                    width: 36.0,
                    height: 36.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Additional form or widgets can be added here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_sharp), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Planned',),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Account',
          ),
        ],
      ),
    );
  }
}
