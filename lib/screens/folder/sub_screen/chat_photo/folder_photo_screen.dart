import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import '../../../../utils/functions.dart';

class FolderPhotoScreen extends StatelessWidget {
  const FolderPhotoScreen({super.key, required this.folderId});

  final int folderId;

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    // Folder? folder = folderViewModel.getFolder(folderId: folderId);
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: folderViewModel.currentMarkers.length,
          itemBuilder: (context, index) {
            return Obx(() => folderViewModel.currentMarkers[index].imageData == null
                ? SpinKitSpinningCircle(
              duration: Duration(seconds: 8),
              itemBuilder: (context, index) {
                return Center(
                  child: Image.asset('assets/images/pictory_color.png'),
                );
              },
            )
                : _getPhotoTile(folderViewModel.currentMarkers[index]));
          },
        ));
  }

  Widget _getPhotoTile(PictoMarker marker) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () async {
              BoxFit fit = await determineFit(marker.imageData!);
              Get.toNamed(
                "/photo",
                arguments: {
                  "photo": marker.photo,
                  "data": marker.imageData,
                  "fit": fit,
                },
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: marker.imageData != null
                    ? Image.memory(
                        marker.imageData!,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (context, object, trace) {
                          return Image.asset(
                            'assets/images/picto_logo.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
