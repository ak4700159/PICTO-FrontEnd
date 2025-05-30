import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/photo_manager_service/photo_manager_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../../../config/app_config.dart';
import '../../../../models/photo.dart';
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
  List<PictoMarker> aroundPhotos = [];

  @override
  void initState() {
    super.initState();
    _startDownloadAllImages();
  }

  Future<void> _startDownloadAllImages() async {
    Set<String> locationNames = {};

    // 추천 이미지 추가 -> 대표 사진 주변 사진 추가하기
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    for(PictoMarker marker in widget.markers) {
      if(googleMapViewModel.currentStep == "large") {
        locationNames.add(marker.photo.location.split(' ')[0]);
      } else if(googleMapViewModel.currentStep == "middle") {
        locationNames.add(marker.photo.location.split(' ')[1]);
      } else {
        locationNames.add(marker.photo.location.split(' ')[2]);
      }
    }

    // 대표 사진 지역 주변으로 주변 사진 검색
    for(String locationName in locationNames) {
      List<Photo> temp = await PhotoManagerApi().getRandomPhotosByLocation(locationName: locationName, count: 10, eventType: "random");
      aroundPhotos.addAll(temp.map((p) => PictoMarker(photo: p, type: PictoMarkerType.aroundPhoto)).toList());
    }

    // 중복 요소 제거
    aroundPhotos.removeWhere((aroundPhoto) =>
        widget.markers.any((p) => p.photo.photoId == aroundPhoto.photo.photoId));

    int completed = 0;
    int total = widget.markers.where((m) => m.imageData == null).length + aroundPhotos.length;
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

    if(aroundPhotos.isNotEmpty) {
      for(int i = 0 ;i < aroundPhotos.length; i++) {
        tasks.add(() async {
          try {
            final data = await PhotoStoreApi().downloadPhoto(
              photoId: aroundPhotos[i].photo.photoId,
              scale: 0.5,
            );
            aroundPhotos[i].imageData = data;
          } catch (e) {
            print("[ERROR] Failed to download image for photoId ${aroundPhotos[i].photo.photoId}");
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
            height: context.mediaQuery.size.height * 0.4,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2행
                // mainAxisSpacing: 2,
                // crossAxisSpacing: 2,
                childAspectRatio: 1.1,
              ),
              itemCount: aroundPhotos.length,
              itemBuilder: (context, index) {
                final marker = aroundPhotos[index];
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
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 0.5)
                          ]
                      ),
                      width: context.mediaQuery.size.width * 0.8,
                      // height: context.mediaQuery.size.width * 0.9,
                      child: Column(
                        children: [
                          SizedBox(
                            width: context.mediaQuery.size.height * 0.17,
                            height: context.mediaQuery.size.height * 0.17,
                            child: AnimatedMarkerWidget(
                              type: marker.type,
                              imageData: marker.imageData,
                            ),
                          ),
                          Text(
                            marker.photo.location.split(' ').take(3).join(' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
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
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
