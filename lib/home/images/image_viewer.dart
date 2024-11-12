import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<String?> imagePaths;

  const ImageViewer({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            // Navigate back to the previous page
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = imagePaths[index];
            if (imagePath != null) {
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.0,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    cacheWidth: null,
                    cacheHeight: null,
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "لا توجد صورة",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
