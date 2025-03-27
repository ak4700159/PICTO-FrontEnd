import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/photo_manager_service/handler.dart';
import 'package:picto_frontend/services/photo_store_service/handler.dart';

import '../../../../../models/photo.dart';

// -------컨버터의 주요역할
// 1. Photo(Photo Manager API 호출) -> PictoMarker(Photo Strore API 호출) -> GoogleMarker(in GoogleMapViewModel)
// 2. 중복 확인(previous vs before) -> Set 자료형 이용

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
      List<Photo> aroundPhotos = await PhotoManagerHandler().getAroundPhotos();

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
      return newRepresentativePhotos.map((photo) => PictoMarker.fromPhoto(photo, PictoMarkerType.representativePhoto)).toList();
    } catch(e) {
      print("[ERROR] MarkerConverter error -> getRepresentativePhotos function error");
    }
    return [];
  }

  // 다른 사용자로부터 공유받은 이미지 추가
  Future<List<PictoMarker>> addAroundPhoto(Photo sharedPhoto) async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      // 공유된 사진?
      // List<Photo> combinedAroundPhotos = await PhotoManagerHandler().getRepresentative(count: 10, eventType: "top", locationType: googleMapViewModel.currentStep);
      // return combinedAroundPhotos.map((photo) => PictoMarker.fromPhoto(photo, 4)).toList();
    } catch(e) {
      print("[ERROR] MarkerConverter error -> addAroundPhoto function error");
    }
    return [];
  }
}