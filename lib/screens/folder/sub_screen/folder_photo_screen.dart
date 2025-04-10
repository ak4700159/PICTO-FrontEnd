import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/marker_widget.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';

import '../../../config/app_config.dart';
import '../../../models/folder.dart';
import '../../../services/photo_store_service/photo_store_api.dart';
import '../../photo/photo_view_model.dart';

class FolderPhotoScreen extends StatelessWidget {
  const FolderPhotoScreen({super.key, required this.folderId});
  final int folderId;

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    Folder? folder = folderViewModel.getFolder(folderId: folderId);
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: folder?.photos.length ?? 0,
      itemBuilder: (context, index) {
        return FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null || snapshot.data == false) {
              return CircularProgressIndicator(color: AppConfig.mainColor,);
            } else if (snapshot.hasError) {
              return Image.asset(
                'assets/images/picto_logo.png',
                fit: BoxFit.cover,
              );
            } else {
              Uint8List? data = snapshot.data;
              return GestureDetector(
                onTap: () async {
                  PhotoViewModel photoViewModel = Get.find<PhotoViewModel>();
                  BoxFit fit = await photoViewModel.determineFit(data!);
                  Get.toNamed("/photo", arguments: {
                    "photo": folder.photos[index],
                    "data": data,
                    "fit": fit,
                  });
                },
                child: MarkerWidget(
                  type: PictoMarkerType.folderPhoto,
                  imageData: data,
                ),
              );
            }
          },
          future: PhotoStoreHandler().downloadPhoto(folder!.photos[index].photoId),
        );
      },
    );
  }

}
