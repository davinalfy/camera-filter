import 'package:flutter/material.dart';
import 'filter_carousel.dart';

// Ubah menjadi StatefulWidget agar bisa mengubah state filter
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Color appliedFilter = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture - 1122140092')),
      body: PhotoFilterCarousel(imagePath: widget.imagePath),
    );
  }
}