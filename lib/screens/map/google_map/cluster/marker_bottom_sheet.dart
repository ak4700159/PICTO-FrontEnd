import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/photo_store_service/photo_store_api.dart';
import '../../../../utils/functions.dart';
import '../marker/animated_marker_widget.dart';
import '../marker/picto_marker.dart';

class MarkerListBottomSheet extends StatefulWidget {
  final List<PictoMarker> markers;

  const MarkerListBottomSheet({required this.markers, super.key});

  @override
  State<MarkerListBottomSheet> createState() => _MarkerListBottomSheetState();
}

class _MarkerListBottomSheetState extends State<MarkerListBottomSheet> {
  double progress = 0.0;
  bool loadingComplete = false;

  @override
  void initState() {
    super.initState();
    _startDownloadAllImages();
  }

  Future<void> _startDownloadAllImages() async {
    int completed = 0;
    int total = widget.markers.where((m) => m.imageData == null).length;

    if (total == 0) {
      setState(() {
        progress = 1.0;
        loadingComplete = true;
      });
      return;
    }

    final tasks = <Future<void>>[];

    for (int i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      if (marker.imageData == null) {
        tasks.add(() async {
          try {
            final data = await PhotoStoreApi().downloadPhoto(
              photoId: marker.photo.photoId,
              scale: 0.5,
            );
            marker.imageData = data;
          } catch (e) {
            print("[ERROR] Failed to download image for photoId ${marker.photo.photoId}");
          }

          completed++;
          // UI 갱신은 메인 스레드에서
          if (mounted) {
            setState(() {
              progress = completed / total;
            });
          }
        }());
      }
    }

    await Future.wait(tasks);

    if (mounted) {
      setState(() {
        loadingComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loadingComplete) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "사진을 불러오는 중입니다...",
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              color: Colors.white,
              minHeight: 20,
            ),
            const SizedBox(height: 10),
            Text(
              "${(progress * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.markers.length,
      itemBuilder: (context, index) {
        final marker = widget.markers[index];
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.3,
            child: GestureDetector(
              onTap: () async {
                BoxFit fit = await determineFit(marker.imageData!);
                Get.toNamed("/photo", arguments: {
                  "photo": marker.photo,
                  "data": marker.imageData,
                  "fit": fit,
                });
              },
              child: AnimatedMarkerWidget(
                type: marker.type,
                imageData: marker.imageData,
              ),
            ),
          ),
        );
      },
    );
  }
}
