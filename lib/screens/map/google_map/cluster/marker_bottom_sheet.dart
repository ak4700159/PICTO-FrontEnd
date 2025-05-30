import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../../../config/app_config.dart';
import '../../../../models/user.dart';
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
    // 추천 이미지 추가 -> 주변 사진

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
              borderRadius: BorderRadius.circular(30),
              value: progress,
              color: Colors.white,
              minHeight: 20,
            ),
            const SizedBox(height: 10),
            Text(
              "${(progress * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: BorderDirectional(bottom: BorderSide(width: 2, color: Colors.grey))),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                Text(
                  "  대표 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: context.mediaQuery.size.height * 0.35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.markers.length,
              itemBuilder: (context, index) {
                final marker = widget.markers[index];
                return Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      BoxFit fit = await determineFit(marker.imageData!);
                      User? user = await UserManagerApi().getUserByUserId(userId: (marker.photo.userId!));
                      Get.toNamed("/photo", arguments: {
                        "photo": marker.photo,
                        "data": marker.imageData,
                        "user": user!,
                        "fit": fit,
                      });
                    },
                    child: SizedBox(
                      width: context.mediaQuery.size.height * 0.3,
                      height: context.mediaQuery.size.height * 0.5,
                      child: Column(
                        children: [
                          SizedBox(
                            width: context.mediaQuery.size.height * 0.3,
                            height: context.mediaQuery.size.height * 0.3,
                            child: AnimatedMarkerWidget(
                              type: marker.type,
                              imageData: marker.imageData,
                            ),
                          ),
                          Text(
                            marker.photo.location.split(' ').take(3).join(' '),
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            formatDateKorean(marker.photo.updateDatetime ?? 0).substring(0, "0000년 00월 00일".length),
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: BorderDirectional(bottom: BorderSide(width: 2, color: Colors.grey))),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.blue,
                ),
                Text(
                  "   주변 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: context.mediaQuery.size.height * 0.35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.markers.length,
              itemBuilder: (context, index) {
                final marker = widget.markers[index];
                return Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      BoxFit fit = await determineFit(marker.imageData!);
                      User? user = await UserManagerApi().getUserByUserId(userId: (marker.photo.userId!));
                      Get.toNamed("/photo", arguments: {
                        "photo": marker.photo,
                        "data": marker.imageData,
                        "user": user!,
                        "fit": fit,
                      });
                    },
                    child: SizedBox(
                      width: context.mediaQuery.size.height * 0.3,
                      height: context.mediaQuery.size.height * 0.5,
                      child: Column(
                        children: [
                          SizedBox(
                            width: context.mediaQuery.size.height * 0.3,
                            height: context.mediaQuery.size.height * 0.3,
                            child: AnimatedMarkerWidget(
                              type: marker.type,
                              imageData: marker.imageData,
                            ),
                          ),
                          Text(
                            marker.photo.location.split(' ').take(3).join(' '),
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            formatDateKorean(marker.photo.updateDatetime ?? 0).substring(0, "0000년 00월 00일".length),
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
