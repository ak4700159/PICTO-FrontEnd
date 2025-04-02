import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';

// ClusterItem 은 Mixin으로 구현되어 있기에 with 키워드를 사용해야 된다.
class PictoItem with ClusterItem {
  final PictoMarker pictoMarker;

  PictoItem({required this.pictoMarker});

  @override
  LatLng get location => LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng);
}
