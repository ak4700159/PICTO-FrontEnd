import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/map/google_map/cluster/marker_bottom_sheet.dart';
import 'package:picto_frontend/screens/map/google_map/cluster/picto_cluster_item.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import '../../../../config/app_config.dart';
import '../../../../models/user.dart';
import '../../../../services/user_manager_service/user_api.dart';
import '../../../../utils/functions.dart';
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
    print("[DEBUG] previous filter : cluster count: ${cluster.items.length}, isMultiple: ${cluster.isMultiple}");
    // List<PictoItem> buildMarkers = filterByUserConfig(target: cluster.items.toList());
    // 가장 좋아요를 많이 맏은 사진
    List<PictoMarker> markers = {
      for (var pictoItem in cluster.items) pictoItem.pictoMarker.photo.photoId: pictoItem.pictoMarker
    }.values.toList();
    final mostLiked = markers.toList().reduce((a, b) => a.photo.likes > b.photo.likes ? a : b);
    mostLiked.onTap = () {
      if (cluster.isMultiple && (markers.length != 1)) {
        _openClusterBottomSheet(cluster.items.map((e) => e.pictoMarker).toList());
      } else {
        _setSinglePhoto(mostLiked);
      }
    };
    mostLiked.imageData ??= await PhotoStoreApi().downloadPhoto(
      photoId: mostLiked.photo.photoId,
      scale: 0.3,
    );
    return mostLiked.toGoogleMarker(most: true);
  }

  // 마커 전체 업데이트
  void _updateMarkers(Set<Marker> markers) async {
    print('[INFO] cluster marker update markers length : ${markers.length}');
    final googleViewModel = Get.find<GoogleMapViewModel>();
    for (final marker in markers) {
      googleViewModel.currentMarkers.add(marker);
    }
  }

  void _openClusterBottomSheet(List<PictoMarker> markers) {
    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            height: context.mediaQuery.size.height * 0.8,
            width: context.mediaQuery.size.width,
            child: MarkerListBottomSheet(
              markers: markers,
            ),
          );
        },
      ),
      isScrollControlled : true,
    );
  }

  void _setSinglePhoto(PictoMarker marker) {
    var googleMapViewModel = Get.find<GoogleMapViewModel>();
    googleMapViewModel.customInfoWindowController.addInfoWindow!(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 25,
              child: FloatingActionButton(
                backgroundColor: AppConfig.mainColor,
                onPressed: () async {
                  BoxFit fit = await determineFit(marker.imageData!);
                  User? user = await UserManagerApi().getUserByUserId(userId: (marker.photo.userId!));
                  Get.toNamed(
                    "/photo",
                    arguments: {
                      "photo": marker.photo,
                      "data": marker.imageData,
                      "user": user!,
                      "fit": fit,
                    },
                  );
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

  List<PictoItem> filterByUserConfig({required List<PictoItem> target}) {
    final userConfig = Get.find<UserConfig>();
    target.removeWhere((p) => userConfig.getMarkerFilter().contains(p.pictoMarker.type));
    return target;
  }
}
