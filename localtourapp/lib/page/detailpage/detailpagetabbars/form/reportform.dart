import 'package:flutter/material.dart';

class ReportForm extends StatefulWidget {
  final String message;

  const ReportForm({Key? key, required this.message}) : super(key: key);

  // Static method to display the ReportForm dialog
  static void show(BuildContext context, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel:
      MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: ReportForm(message: message),
            ),
          ),
        );
      },
    );
  }

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final TextEditingController _controller = TextEditingController();

  // Key for the form to manage validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to display a snackbar notification
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        Text(
          widget.message,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        // Report text area within a Form widget
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            maxLength: 500,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Describe the issue...",
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please, describe your issue';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        // Report button
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // If the form is valid (text is not empty), proceed
              // Display a snackbar notification
              _showSnackbar('Your report has been sent, we will consider it.');
              Navigator.pop(context); // Close the form after reporting
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA1A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          ),
          child: const Text(
            "Report",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
