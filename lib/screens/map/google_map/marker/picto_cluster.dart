import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_cluster_item.dart';

class PictoCluster{
  late cluster.ClusterManager<PictoItem> clusterManager;

  // void initClusterManager() {
  //   final GoogleMapViewModel googleMapViewModel = Get.find<GoogleMapViewModel>();
  //   clusterManager = cluster.ClusterManager<PictoItem>(
  //     googleMapViewModel.currentMarkers.map((p) => PictoItem(pictoMarker: p)).toList(),
  //     _updateMarkers,
  //     markerBuilder: _markerBuilder,
  //     stopClusteringZoom: 17,
  //   );
  // }

  // Future<BitmapDescriptor> _getThumbnailImage(Photo photo) async {
  //   final bytes = await yourImageLoader(photo.photoPath); // Uint8List
  //   final codec = await instantiateImageCodec(bytes, targetWidth: 100);
  //   final frame = await codec.getNextFrame();
  //   final data = await frame.image.toByteData(format: ImageByteFormat.png);
  //   return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  // }
  //
  // Future<Marker> _markerBuilder(Cluster<PictoItem> cluster) async {
  //   final mostLiked = cluster.items.reduce((a, b) => a.photo.likes > b.photo.likes ? a : b);
  //   final image = await _getThumbnailImage(mostLiked.photo); // 썸네일 비트맵으로 변환
  //
  //   return Marker(
  //     markerId: MarkerId(cluster.getId()),
  //     position: cluster.location,
  //     icon: image,
  //     onTap: () {
  //       if (cluster.isMultiple) {
  //         Get.to(() => ClusterPhotoListScreen(items: cluster.items.map((e) => e.photo).toList()));
  //       } else {
  //         // 단일 사진인 경우 상세보기
  //         Get.toNamed('/photo', arguments: {"photo": mostLiked.photo});
  //       }
  //     },
  //   );
  // }
}