import 'dart:io';
import 'package:flutter/material.dart';

class FullEventPhotoViewer extends StatelessWidget {
  final String eventPhotoUrl;

  const FullEventPhotoViewer({
    Key? key,
    required this.eventPhotoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true, // Allow panning
              minScale: 0.5, // Minimum zoom-out scale
              maxScale: 4.0, // Maximum zoom-in scale
              child: eventPhotoUrl.startsWith('http')
                  ? Image.network(
                eventPhotoUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.red, size: 50),
                  );
                },
              )
                  : Image.file(
                File(eventPhotoUrl),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.red, size: 50),
                  );
                },
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
