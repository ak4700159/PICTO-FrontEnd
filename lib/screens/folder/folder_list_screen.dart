import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../profile/profile_view_model.dart';
import 'folder_frame.dart';

class FolderListScreen extends StatelessWidget {
  FolderListScreen({super.key});

  final List<String> folderNames = ["PICTO", "가족여행", "크리스마스"];

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Get.find<ProfileViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text("${profileViewModel.accountName.value}의 폴더 목록"),
        automaticallyImplyLeading : false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: folderNames.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FolderFrame()),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 5),
                Text(folderNames[index], style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}


