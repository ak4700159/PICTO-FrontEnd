
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FolderPhotoScreen extends StatelessWidget {
  const FolderPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        );
      },
    );
  }
}
