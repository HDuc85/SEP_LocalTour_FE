import 'package:flutter/material.dart';
import 'package:localtourapp/services/report_service.dart';

class ReportForm extends StatefulWidget {
  final String message;
  final String? userId;
  final int?  placeId;
  final String language;
  final ValueChanged<String>? onSubmit; // Changing the callback to pass the report message

  const ReportForm({
    Key? key,
    required this.message,
    this.userId,
    this.placeId,
    this.onSubmit,
    required this.language
  }) : super(key: key);

  // Static method to display the ReportForm dialog
  static void show(BuildContext context, String message,String? userId, int? placeId , String language, {ValueChanged<String>? onSubmit}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Set the desired background color
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: ReportForm(message: message,userId: userId,placeId: placeId, onSubmit: onSubmit, language: language,),
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
  final ReportService _reportService = ReportService();
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

  Future<void> _handleReportSubmission() async {
    if (_formKey.currentState?.validate() ?? false) {
      // If the form is valid (text is not empty)
      final reportMessage = _controller.text.trim();
      String message = '';
      if(widget.userId != null){
         message = await _reportService.reportUser(widget.userId!, reportMessage);
      }
      if(widget.placeId != null && widget.placeId! > 0){
         message = await _reportService.reportPlace(widget.placeId!, reportMessage);
      }


      widget.onSubmit?.call(message);
      _showSnackbar('$message');
      Navigator.pop(context); // Close the form after reporting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Adjusts based on content size
      children: [
        Text(
         widget.language != 'vi' ? "Report" : 'Báo cáo',
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
            decoration:  InputDecoration(
              border: OutlineInputBorder(),
              hintText: widget.language != 'vi' ?"Describe the issue..." : "Mô tả vấn đề ...",
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return widget.language != 'vi' ?'Please, describe your issue':'Xin hãy mô tả vấn đề của bạn ....';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        // Report button
        ElevatedButton(
          onPressed: _handleReportSubmission,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA1A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          ),
          child:  Text(
            widget.language != 'vi' ?"Report" : 'Báo cáo',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white
            ),
          ),
        ),
      ],
    );
  }
}
