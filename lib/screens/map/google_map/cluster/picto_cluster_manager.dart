import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/google_map/cluster/picto_cluster_item.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import '../../../../config/app_config.dart';
import '../../../photo/photo_view_model.dart';
import '../marker/marker_widget.dart';
import '../marker/picto_marker.dart';

class PictoClusterManager {
  PictoClusterManager._();

  static final PictoClusterManager _manager = PictoClusterManager._();

  factory PictoClusterManager() {
    return _manager;
  }

  late cluster.ClusterManager<PictoItem> manager;

  // 클러스터 매니저 초기화
  void initClusterManager() {
    final GoogleMapViewModel googleMapViewModel = Get.find<GoogleMapViewModel>();
    manager = cluster.ClusterManager<PictoItem>(
      googleMapViewModel.currentPictoMarkers.map((p) => PictoItem(pictoMarker: p)).toList(),
      _updateMarkers, // 마커가 업데이트될 때 마다 호출됨
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5], // 클러스터 해상도 단계 지정
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 16, //
      extraPercent: 0.2, // 외곽 추가 거리 비율
    );
  }

  // 클러스터 매니저에서 생성하는 마커
  Future<Marker> _markerBuilder(cluster.Cluster<PictoItem> cluster) async {
    print("[DEBUG] cluster count: ${cluster.items.length}, isMultiple: ${cluster.isMultiple}");
    // 가장 좋아요를 많이 맏은 사진
    List<PictoMarker> markers = {
      for (var pictoItem in cluster.items)
        pictoItem.pictoMarker.photo.photoId: pictoItem.pictoMarker
    }.values.toList();
    final mostLiked = markers.toList().reduce((a, b) => a.photo.likes > b.photo.likes ? a : b);
    mostLiked.onTap = () {
      if (cluster.isMultiple && (markers.length != 1)) {
        _openClusterBottomSheet(cluster.items.map((e) => e.pictoMarker).toList());
      } else {
        _setSinglePhoto(mostLiked);
      }
    };
    mostLiked.imageData ??= await PhotoStoreHandler().downloadPhoto(mostLiked.photo.photoId);
    return mostLiked.toGoogleMarker(most: true);
  }

  // 마커 전체 업데이트
  void _updateMarkers(Set<Marker> markers) async {
    print('[INFO] cluster marker update markers length : ${markers.length}');
    final googleViewModel = Get.find<GoogleMapViewModel>();
    for (final marker in markers) {
      await Future.delayed(Duration(milliseconds: 70)); // 애니메이션 간격
      googleViewModel.currentMarkers.add(marker);
      // googleViewModel.update(); // GetX 뷰모델이 Obx 방식이면 필요
    }
    // googleViewModel.currentMarkers.addAll(markers);
  }

  void _openClusterBottomSheet(List<PictoMarker> markers) {
    Get.bottomSheet(
        ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          itemCount: markers.length,
          itemBuilder: (BuildContext context, int index) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
                child: GestureDetector(
                  onTap: () async {
                    PhotoViewModel photoViewModel = Get.find<PhotoViewModel>();
                    BoxFit fit = await photoViewModel.determineFit(markers[index].imageData!);
                    Get.toNamed("/photo", arguments: {
                      "photo": markers[index].photo,
                      "data": markers[index].imageData,
                      "fit": fit,
                    });
                  },
                  child: markers[index].imageData == null
                      ? FutureBuilder(
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null || snapshot.data == false) {
                              return Center(child: CircularProgressIndicator(color: AppConfig.mainColor,));
                            } else if (snapshot.hasError) {
                              return Image.asset(
                                'assets/images/picto_logo.png',
                                fit: BoxFit.cover,
                              );
                            } else {
                              Uint8List data = snapshot.data;
                              markers[index].imageData = data;
                              return MarkerWidget(
                                type: markers[index].type,
                                imageData: markers[index].imageData,
                              );
                            }
                          },
                          future: PhotoStoreHandler().downloadPhoto(markers[index].photo.photoId),
                        )
                      : MarkerWidget(
                          type: markers[index].type,
                          imageData: markers[index].imageData,
                        ),
                ),
              ),
            );
          },
        ),
        shape: BeveledRectangleBorder());
  }

  void _setSinglePhoto(PictoMarker marker) {
    var googleMapViewModel = Get.find<GoogleMapViewModel>();
    PhotoViewModel photoViewModel = Get.find<PhotoViewModel>();
    googleMapViewModel.customInfoWindowController.addInfoWindow!(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 25,
              child: FloatingActionButton(
                backgroundColor: AppConfig.mainColor,
                onPressed: () async {
                  BoxFit fit = await photoViewModel.determineFit(marker.imageData!);
                  Get.toNamed("/photo", arguments: {
                    "photo": marker.photo,
                    "data": marker.imageData,
                    "fit": fit,
                  });
                },
                child: Text(
                  "상세 보기",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        LatLng(marker.photo.lat, marker.photo.lng));
  }
}
