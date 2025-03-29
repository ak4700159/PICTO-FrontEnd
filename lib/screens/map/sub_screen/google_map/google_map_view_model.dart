import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/marker_converter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/marker_widget.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/picto_marker.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

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
  late Marker userMarker;

  @override
  void onInit() async {
    // 지도 양식 로딩
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    userMarker = Marker(
      position: LatLng(currentLat.value, currentLng.value),
      markerId: MarkerId("user"),
      icon: await MarkerWidget(
        type: PictoMarkerType.userPos,
      ).toBitmapDescriptor(
        logicalSize: const Size(150, 150),
        imageSize: const Size(150, 150),
      ),
      // 커스텀 InfoWindow 만드는 법 찾는 중
      infoWindow: InfoWindow(title: "현재 위치"),
    );
    super.onInit();
  }

  // Future<Uint8List> _loadAssetImageAsBytes(String path) async {
  //   final ByteData byteData = await rootBundle.load(path);
  //   return byteData.buffer.asUint8List();
  // }

  // 현재 배율에 따라 상태 변화 //
  Set<Marker> returnMarkerAccordingToZoom() {
    // 1.
    // 2. Marker Converter 를 통해 실제 구글 마커로 띄울 수 있도록 사진 다운로드
    switch (currentStep) {
      case "":
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
    if (pos.zoom >= 2 && pos.zoom < 7) {
      currentStep = "small";
    } else if (pos.zoom >= 7 && pos.zoom < 12) {
      currentStep = "middle";
    } else {
      currentStep = "large";
    }

    // 화면 중앙 정보 로딩
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
    currentZoom.value = 14;
    currentCameraPos = CameraPosition(
      target: LatLng(currentLat.value, currentLng.value),
      zoom: 14,
    );
    print("[INFO] now location : ${currentLat.value}/${currentLng.value}\n");

    // 현재 위치 주소를 구독하기
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        currentLat.value = position.latitude;
        currentLng.value = position.longitude;
        _updateUserMarker();
        print("[INFO] get current pos -> lat : ${currentLat.value} / lng : ${currentLng.value}");
      },
    );
  }

  // 로그인 후 내 사진과 공유 폴더 사진 마커 변환
  void initPhotos(List<dynamic> photos) async {
    print("[INFO] init photo ====================");
    List<Photo> initPhotos = photos
        .map((photo) => Photo(
            photoId: photo["photoId"],
            folderId: photo["folderId"],
            userId: photo["userId"],
            photoPath: photo["photoPath"],
            registerDatetime: photo["registerDatetime"],
            updateDatetime: photo["updateDatetime"],
            lat: photo["lat"],
            lng: photo["lng"],
            likes: photo["likes"],
            views: photo["views"],
            location: photo["location"],
            tag: photo["tag"]))
        .toList();

    // Google Marker로 변환
    myPhotos = _converter.convertToPictoMarker(initPhotos.where((photo) => photo.folderId == null).toList());
    folderPhotos = _converter.convertToPictoMarker(initPhotos.where((photo) => photo.folderId != null).toList());
    for (PictoMarker photo in myPhotos) {
      currentMarkers.add(await photo.toGoogleMarker());
    }
    for (PictoMarker photo in folderPhotos) {
      currentMarkers.add(await photo.toGoogleMarker());
    }
    currentMarkers.add(userMarker);
  }

  void _updateUserMarker() async {
    userMarker = Marker(
      markerId: const MarkerId("user"),
      position: LatLng(currentLat.value, currentLng.value),
      icon: await MarkerWidget(type: PictoMarkerType.userPos).toBitmapDescriptor(
        logicalSize: const Size(150, 150),
        imageSize: const Size(150, 150),
      ),
      infoWindow: const InfoWindow(title: "현재 위치"),
    );

    // 마커 셋에서 이전 것 제거 후 다시 추가
    currentMarkers.removeWhere((marker) => marker.markerId.value == "user");
    currentMarkers.add(userMarker);
  }
}
