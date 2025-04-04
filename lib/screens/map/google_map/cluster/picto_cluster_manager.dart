import 'dart:typed_data';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/google_map/cluster/picto_cluster_item.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/marker_widget.dart';

import '../../../../models/photo.dart';

class PictoClusterManager {
  PictoClusterManager._();

  static final PictoClusterManager _manager = PictoClusterManager._();

  factory PictoClusterManager() {
    return _manager;
  }

  late cluster.ClusterManager<PictoItem> clusterManager;

  // 클러스터 매니저 초기화
  void initClusterManager() {
    final GoogleMapViewModel googleMapViewModel = Get.find<GoogleMapViewModel>();
    clusterManager = cluster.ClusterManager<PictoItem>(
      googleMapViewModel.currentPictoMarkers.map((p) => PictoItem(pictoMarker: p)).toList(),
      _updateMarkers,
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 17,
    );
  }

  // 썸네일 이미지 생성하기
  Future<BitmapDescriptor> _getThumbnailImage(Uint8List imageData) async {
    final bytes = imageData; // Uint8List
    final codec = await instantiateImageCodec(bytes, targetWidth: 100);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  // 클러스터 매니저에서 생성하는 마커
  Future<Marker> _markerBuilder(cluster.Cluster<PictoItem> cluster) async {
    // 가장 좋아요를 많이 맏은 사진
    final mostLiked = cluster.items
        .reduce((a, b) => a.pictoMarker.photo.likes > b.pictoMarker.photo.likes ? a : b);
    // final image = await _getThumbnailImage(mostLiked.pictoMarker.imageData!);
    mostLiked.pictoMarker.onTap = () {
      if (cluster.isMultiple) {
        // Get.to(() => ClusterPhotoListScreen(items: cluster.items.map((e) => e.photo).toList()));
        // Get.toNamed('/cluster',
        //     arguments: {"items": cluster.items.map((e) => e.pictoMarker).toList()});
      } else {
        // 단일 사진인 경우 상세보기
        Get.toNamed('/photo', arguments: {"photo": mostLiked.pictoMarker.photo});
      }
    };
    return mostLiked.pictoMarker.toGoogleMarker();
  }

  // 마커 전체 업데이트
  void _updateMarkers(Set<Marker> markers) {
    // 지도에 있는 마커들 전체 교체
    final GoogleMapViewModel googleMapViewModel = Get.find<GoogleMapViewModel>();
    googleMapViewModel.currentMarkers.clear();
    googleMapViewModel.currentMarkers.union(markers);
  }
}
