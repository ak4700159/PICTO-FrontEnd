import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/photo_manager_service/handler.dart';
import 'package:picto_frontend/services/photo_store_service/handler.dart';

import '../../../../../models/photo.dart';

// -------컨버터의 주요역할
// 1. Photo -> PictoMarker -> GoogleMarker
// 2. 중복 확인(previous vs before)
// 3. api 호출?

// -------마커 타입
// 1. 내 사진
// 2. 공유폴더에 올린 다른 사람 사진
// 3. 지역 대표 사진
// 4. 내 주변 사진
class MarkerConverter{
  MarkerConverter._();
  final PhotoStoreHandler photoStoreHandler = PhotoStoreHandler();
  static final MarkerConverter _converter = MarkerConverter._();
  factory MarkerConverter() {
    return _converter;
  }

  // api 호출 (List<Photo>) -> 중복 확인 -> 업데이트(사진 다운로드) -> 화면에 랜더링할 수 있는 PictoMarker로 변환
  Future<List<PictoMarker>> getAroundPhotos() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      List<Photo> newRepresentativePhotos = await PhotoManagerHandler().getAroundPhotos();

    } catch(e) {
      print("[ERROR] MarkerConverter error -> getAroundPhotos function error");
    }
    return [];
  }

  // 지역대표 사진 획득 , 아직 최적화는 안되어 있음
  Future<List<PictoMarker>> getRepresentativePhotos() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      // 지역별, 좋아요순, 상위 10개 항목 검색
      List<Photo> newRepresentativePhotos = await PhotoManagerHandler().getRepresentative(count: 10, eventType: "top", locationType: googleMapViewModel.currentStep);
      return newRepresentativePhotos.map((photo) => PictoMarker.fromPhoto(photo, 3)).toList();
    } catch(e) {
      print("[ERROR] MarkerConverter error -> getRepresentativePhotos function error");
    }
    return [];
  }

  // 실시간 공유 사진 처리
  void addArroundPhoto() {

  }

  // photo manager api 호출 후 Photo json 입력
  // PhotoId를 통해 사진 데이터 다운로드(photo store api 호출)
  // PictoMarker 변환 -> 이전 Set과 비교하여 겹치는 사진이 있는지 확인(자료형이 집합이여서 고려 x)
  // Google Marker로 변환
}