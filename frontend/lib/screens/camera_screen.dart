import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // In a real application, this would involve using the camera to
            // capture an image and then processing it to identify the product.
            // For now, we'll just navigate to the results screen with a
            // hardcoded product ID.
            Navigator.pushReplacementNamed(context, '/results');
          },
          icon: const Icon(Icons.camera),
          label: const Text('Take Picture'),
        ),
      ),
    );
  }
}
