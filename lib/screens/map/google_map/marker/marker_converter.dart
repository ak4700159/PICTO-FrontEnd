import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/photo_manager_service/photo_manager_api.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';

import '../../../../../models/photo.dart';
import '../google_map_view_model.dart';

// -------컨버터의 주요역할
// 1. Photo(Photo Manager API 호출) -> PictoMarker(Photo Strore API 호출) -> GoogleMarker(in GoogleMapViewModel)
// 2. 중복 확인(previous vs before) -> Set 자료형 이용

// -------마커 타입
// 1. 내 사진
// 2. 공유폴더에 올린 다른 사람 사진
// 3. 지역 대표 사진
// 4. 내 주변 사진
class MarkerConverter {
  MarkerConverter._();

  final PhotoStoreHandler photoStoreHandler = PhotoStoreHandler();
  static final MarkerConverter _converter = MarkerConverter._();

  factory MarkerConverter() {
    return _converter;
  }

  // 한꺼번에 PictoMarker로 변환
  Set<PictoMarker> convertToPictoMarker(List<Photo> photos, PictoMarkerType? type) {
    Set<PictoMarker> pictoMarkers = photos
        .map((photo) => PictoMarker(
              photo: photo,
              type:
                  photo.folderId != null ? PictoMarkerType.folderPhoto : PictoMarkerType.userPhoto,
            ))
        .toSet();
    pictoMarkers.forEach((pictoMarker) async {
      // pictoMarker.imageData = await PhotoStoreHandler().downloadPhoto(pictoMarker.photo.photoId);
    });
    return pictoMarkers;
  }

  // api 호출 (List<Photo>) -> 중복 확인 -> 업데이트(사진 다운로드) -> 화면에 랜더링할 수 있는 PictoMarker로 변환
  Future<Set<PictoMarker>> getAroundPhotos() async {
    try {
      List<Photo> aroundPhotos = await PhotoManagerApi().getAroundPhotos();
      return aroundPhotos
          .map((photo) => PictoMarker(photo: photo, type: PictoMarkerType.aroundPhoto))
          .toSet();
    } catch (e) {
      print("[ERROR] MarkerConverter error -> getAroundPhotos function error");
    }
    return {};
  }

  // 지역대표 사진 획득 , 아직 최적화는 안되어 있음
  Future<Set<PictoMarker>> getRepresentativePhotos(int count, String type) async {
    try {
      // 지역별, 좋아요순, 상위 10개 항목 검색
      List<Photo> newRepresentativePhotos = await PhotoManagerApi().getRepresentative(
          count: count, eventType: "top", locationType: type);
      return newRepresentativePhotos
          .map((photo) => PictoMarker.fromPhoto(photo, PictoMarkerType.representativePhoto))
          .toSet();
    } catch (e) {
      print("[ERROR] MarkerConverter error -> getRepresentativePhotos function error");
    }
    return {};
  }

  // 다른 사용자로부터 공유받은 이미지 추가
  void addAroundPhoto(Photo sharedPhoto) async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      googleMapViewModel.aroundPhotos.add(PictoMarker(photo: sharedPhoto, type: PictoMarkerType.aroundPhoto));
    } catch (e) {
      print("[ERROR] MarkerConverter error -> addAroundPhoto function error");
    }
  }

  // 이미지 다운로드
  Future<void> downloadPhotos(Set<PictoMarker> pictoMarkers) async {
    await Future.wait(pictoMarkers.map((pictoMarker) async {
      pictoMarker.imageData ??= await PhotoStoreHandler().downloadPhoto(pictoMarker.photo.photoId);
    }));
  }
}
