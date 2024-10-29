import 'package:flutter/material.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min, // Adjusts based on content size
        children: [
          const Text(
            "Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Have a problem with this place? Report it to us!",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          // Report text area
          TextField(
            controller: _controller,
            maxLength: 500,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Describe the issue...",
            ),
          ),
          const SizedBox(height: 10),
          // Report button
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                // Display a snackbar notification
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your report has been sent, we will consider it.'),
                  ),
                );
                Navigator.pop(context); // Close the form after reporting
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCA1A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            child: const Text(
              "Report",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),

        ],
      );
  }
}
