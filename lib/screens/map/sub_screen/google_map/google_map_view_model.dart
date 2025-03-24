import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/marker_converter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/picto_marker.dart';

class GoogleMapViewModel extends GetxController {
  // ChatGPT 방안 completer 사용하지 말고 GoogleMapController 직접 관리
  GoogleMapController? _googleMapController;
  RxDouble currentLat = 0.0.obs;
  RxDouble currentLng = 0.0.obs;
  RxDouble currentZoom = 0.0.obs;
  RxDouble currentScreenCenterLat = 0.0.obs;
  RxDouble currentScreenCenterLng = 0.0.obs;
  String currentStep = "";
  MarkerConverter _converter = MarkerConverter();
  StreamSubscription<Position>? _positionStreamSubscription;
  late String mapStyleString;
  late CameraPosition currentCameraPos;


  // 지역대표 사진(줌에 따라 변화)
  // small[2~7], middle[7~12], large[12~17]
  // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
  Set<PictoMarker> representativePhotos = <PictoMarker>{};

  // 3km 이내 주변 사진(small)
  Set<PictoMarker> aroundPhotos = <PictoMarker>{};

  // 내 사진(middle)
  Set<PictoMarker> myPhotos = <PictoMarker>{};

  // 공유폴더 사진(middle)
  Set<PictoMarker> folderPhotos = <PictoMarker>{};

  // 현재 선택된 마커들(all zoom)
  RxSet<Marker> currentMarkers = <Marker>{}.obs;

  // 사용자 현재 위치 마커(small)
  late PictoMarker userMarker;

  @override
  void onInit() {
    // 지도 양식 로딩
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    super.onInit();
  }

  // 현재 배율에 따라 상태 변화 //
  Set<Marker> returnMarkerAccordingToZoom() {
    switch (currentStep) {

    }
    return currentMarkers;
  }

  // 화면 이동할 때마다 호출되는 함수
  void onCameraMove(CameraPosition pos) async {
    // 화면 줌 정보
    currentCameraPos = pos;
    currentZoom.value = pos.zoom;

    // small[2~7], middle[7~12], large[12~17]
    // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
    if(pos.zoom >= 2 && pos.zoom <7) {
      currentStep = "small";
    } else if(pos.zoom >= 7 && pos.zoom < 12) {
      currentStep = "middle";
    } else {
      currentStep = "large";
    }

    // 화면 중앙 정보 로딩 -> 최적화에 필요
    try {
      LatLngBounds bounds = await _googleMapController!.getVisibleRegion();
      currentScreenCenterLat.value = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      currentScreenCenterLng.value = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    } catch (e) {
      print("[ERROR] acquired screen location fail");
    }
  }

  void setController(GoogleMapController controller) async {
    try {
      _googleMapController = controller;
      LatLngBounds bounds = await controller.getVisibleRegion();
      currentScreenCenterLat.value = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      currentScreenCenterLng.value = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    } catch (e) {
      print("[ERROR] : controller setting error");
    }
  }

  void moveCurrentPos() async {
    _googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(currentLat.value, currentLng.value), zoom: 17),
    ));
  }

  // 권환 획득
  Future<void> getPermission() async {
    // 위치 정보 획득 가능한지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('permissions are denied');
      }
    }

    // 최초 카메라 설정
    Position position = await Geolocator.getCurrentPosition();
    currentLat.value = position.latitude;
    currentLng.value = position.longitude;
    currentZoom.value = 14.4746;
    currentCameraPos = CameraPosition(
      target: LatLng(currentLat.value, currentLng.value),
      zoom: 14.4746,
    );
    print("[INFO] now location : ${currentLat.value}/${currentLng.value}\n");

    // 현재 위치 주소를 구독하기
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
          (Position position) {
          currentLat.value = position.latitude;
          currentLng.value = position.longitude;
          print("[INFO] get current pos -> lat : ${currentLat.value} / lng : ${currentLng.value}");
      },
    );
  }
}
