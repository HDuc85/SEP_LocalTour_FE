// lib/faq_page.dart

import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  // Define a list of FAQs
  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How to create a schedule?',
      'answer':
      'To create a schedule, navigate to the "Planned" section and tap on "Create Schedule". Follow the prompts to add your events and destinations.'
    },
    {
      'question': 'How to use the map?',
      'answer':
      'Access the map from the main navigation bar. You can search for places, view your current location, and explore nearby attractions.'
    },
    {
      'question': 'How to find a place?',
      'answer':
      'Use the search bar in the map or home screen to enter the name or type of place you are looking for. The app will display matching results.'
    },
    {
      'question': 'How to bookmark a place?',
      'answer':
      'On the place details page, tap the bookmark icon to save the place to your bookmarks. You can access your bookmarks from the "Bookmark" section.'
    },
    {
      'question': 'How to create my post?',
      'answer':
      'Go to the "Account" section and tap on "Create Post". Enter your content, add images if desired, and submit your post for others to see.'
    },
    {
      'question':
      'How to see other people\'s posts and schedules?',
      'answer':
      'Navigate to the "Explore" section to view posts and schedules shared by other users. You can like, comment, or follow their profiles.'
    },
    {
      'question': 'How to report a place/person?',
      'answer':
      'On the place or user profile page, tap the "Report" button. Provide the necessary details, and our team will review your report promptly.'
    },
    {
      'question': 'How to see the weather?',
      'answer':
      'Access the "Weather" section from the main navigation bar to view current weather conditions and forecasts for your selected locations.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'), // Consider localizing
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.question_answer, color: Colors.blue),
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
