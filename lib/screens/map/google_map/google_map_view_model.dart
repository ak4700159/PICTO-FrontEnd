import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/services/photo_store_service/handler.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../utils/etc.dart';
import 'marker/marker_converter.dart';
import 'marker/marker_widget.dart';
import 'marker/picto_marker.dart';

class GoogleMapViewModel extends GetxController {
  // ChatGPT 방안 completer 사용하지 말고 GoogleMapController 직접 관리
  GoogleMapController? _googleMapController;
  RxDouble currentLat = 0.0.obs;
  RxDouble currentLng = 0.0.obs;
  RxDouble currentZoom = 0.0.obs;
  late LatLngBounds bounds;
  RxDouble currentScreenCenterLat = 0.0.obs;
  RxDouble currentScreenCenterLng = 0.0.obs;
  RxBool isCurrentPosInScreen = true.obs;
  bool needUpdate = false;
  String currentStep = "";
  final MarkerConverter _converter = MarkerConverter();

  // 사진 공유 스트림(서버로부터만 전달받음)
  StreamSubscription<Position>? _positionStreamSubscription;

  // 마커 클릭 시 커스텀 위젯 컨트롤러
  final CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  late String mapStyleString;
  late CameraPosition currentCameraPos;

  // 지역대표 사진(줌에 따라 변화)
  // small[2~7], middle[7~12], large[12~17]
  // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
  Map<String, Set<PictoMarker>> representativePhotos = {
    "small": <PictoMarker>{},
    "middle": <PictoMarker>{},
    "large": <PictoMarker>{},
  };

  // 3km 이내 주변 사진(small)
  Set<PictoMarker> aroundPhotos = <PictoMarker>{};

  // 내 사진(middle)
  Set<PictoMarker> myPhotos = <PictoMarker>{};

  // 공유폴더 사진(middle)
  Set<PictoMarker> folderPhotos = <PictoMarker>{};

  // 현재 선택된 마커들(all zoom)
  RxSet<PictoMarker> currentPictoMarkers = <PictoMarker>{}.obs;
  RxSet<Marker> currentMarkers = <Marker>{}.obs;

  // 사용자 현재 위치 마커(small)
  late Marker userMarker;

  // 사진 중복 호출 방지
  final Throttle _callUpdatePhoto = Throttle(
    const Duration(seconds: AppConfig.throttleSec),
    initialValue: null,
    checkEquality: false,
  );

  @override
  void onInit() async {
    // 지도 양식 로딩
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    // 사용자 마커 생성
    userMarker = await _buildUserMarker();
    _callUpdatePhoto.values.listen((event) {
      _updateAllMarker();
    });
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _googleMapController?.dispose();
    _positionStreamSubscription?.cancel();
    customInfoWindowController.dispose();
    super.dispose();
  }

  // 화면 이동할 때마다 호출되는 함수
  void onCameraMove(CameraPosition pos) async {
    customInfoWindowController.onCameraMove!();

    // 화면 줌 정보
    currentCameraPos = pos;
    currentZoom.value = pos.zoom;

    // 화면 중앙 정보 로딩
    try {
      bounds = await _googleMapController!.getVisibleRegion();
      currentScreenCenterLat.value = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      currentScreenCenterLng.value = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      final currentPos = LatLng(currentLat.value, currentLng.value);

      // small[2~7], middle[7~12], large[12~17]
      // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
      if (pos.zoom >= 2 && pos.zoom < 7) {
        currentStep = "large";
        needUpdate = true;
        isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, bounds);
      } else if (pos.zoom >= 7 && pos.zoom < 12) {
        currentStep = "middle";
        needUpdate = true;
        isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, bounds);
        // 화면 안에 있을 경우 주변 사진만 보여준다.
      } else {
        if (currentStep != "small" ||
            isCurrentPosInScreen.value != _isPointInsideBounds(currentPos, bounds)) {
          currentStep = "small";
          needUpdate = true;
          isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, bounds);
        }
      }
    } catch (e) {
      print("[ERROR] acquired screen location fail");
    }
  }

  // 카메라 이동이 끝났을 때 호출
  void onCameraIdle() {
    if (needUpdate) {
      _callUpdatePhoto.setValue(null);
      needUpdate = false;
    }
  }

  // 지도에 탭하면 보기창 없애기
  void onTap(position) {
    customInfoWindowController.hideInfoWindow!();
  }

  // 지도가 새롭게 생성될 때 호출
  void setController(GoogleMapController controller) async {
    try {
      _googleMapController = controller;
      customInfoWindowController.googleMapController = controller;
      LatLngBounds bounds = await controller.getVisibleRegion();
      currentScreenCenterLat.value = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      currentScreenCenterLng.value = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    } catch (e) {
      print("[ERROR] : controller setting error");
    }
  }

  // 현재 위치로 이동
  void moveCurrentPos() async {
    _googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(currentLat.value, currentLng.value), zoom: 17),
    ));
  }

  // 위치 권환 획득
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

  // 로그인 후 내 사진과 공유 폴더 사진, 지역 대표 사진 마커 변환
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

    // 초기 화면에 필요한 사진 로드 (내 사진, 공유 폴더 사진, 주변 사진)
    myPhotos = _converter.convertToPictoMarker(
        initPhotos.where((photo) => photo.folderId == null).toList(), PictoMarkerType.userPhoto);
    folderPhotos = _converter.convertToPictoMarker(
        initPhotos.where((photo) => photo.folderId != null).toList(), PictoMarkerType.folderPhoto);
    aroundPhotos = await _converter.getAroundPhotos();
    for (PictoMarker photo in myPhotos) {
      currentPictoMarkers.add(photo);
    }
    for (PictoMarker photo in folderPhotos) {
      currentPictoMarkers.add(photo);
    }
    _converter.downloadPhotos(aroundPhotos);
    for (PictoMarker photo in aroundPhotos) {
      currentPictoMarkers.add(photo);
    }
    currentMarkers.add(userMarker);
  }

  // 사용자 위치 마커 업데이트
  void _updateUserMarker() async {
    userMarker = await _buildUserMarker();
    // 마커 셋에서 이전 것 제거 후 다시 추가
    if (currentStep != "large") {
      currentMarkers.removeWhere((marker) => marker.markerId.value == "user");
      currentMarkers.add(userMarker);
    }
  }

  // 전체 마커 업데이트
  // 1. 화면 정보에 맞게 사진 데이터 호출
  // 2. photo -> pictoMarker -> googleMarker
  // 3. 사진 다운로드, 중간에 화면 정보가 바뀌면 중지
  Future<void> _updateAllMarker() async {
    if (currentStep == "large") {
      // 지역 대표 사진만 로딩
      currentPictoMarkers.clear();
      currentMarkers.clear();

      _loadRepresentative(currentStep);
    } else if (currentStep == "middle") {
      // 지역 대표 사진 + 내 위치 + 폴더 사진 + 내 사진
      currentPictoMarkers.clear();
      currentMarkers.clear();

      _loadRepresentative(currentStep);
      _loadFolder(currentStep);
      _loadMyPhotos();
      currentMarkers.add(userMarker);
    } else {
      // (지역 대표 사진 OR 주변 사진) + 내 위치 + 폴더 사진 + 내 사진
      currentPictoMarkers.clear();
      currentMarkers.clear();

      if (isCurrentPosInScreen.value) {
        _loadAround(currentStep);
      } else {
        _loadRepresentative(currentStep);
      }
      _loadFolder(currentStep);
      _loadMyPhotos();
      currentMarkers.add(userMarker);
    }
  }

  Future<void> updateAllMarkersByPeriod(String period) async {
    // 기준 시간 계산
    final now = DateTime.now();
    DateTime periodThreshold;

    switch (period) {
      case "일년":  periodThreshold = now.subtract(Duration(days: 365)); break;
      case "한달":  periodThreshold = now.subtract(Duration(days: 30)); break;
      case "일주일":periodThreshold = now.subtract(Duration(days: 7)); break;
      case "하루":  periodThreshold = now.subtract(Duration(days: 1)); break;
      default:     periodThreshold = DateTime.fromMillisecondsSinceEpoch(0); // 전체 포함
    }

    currentPictoMarkers.removeWhere((marker) => !withinPeriod(marker, periodThreshold));
    aroundPhotos.removeWhere((marker) => !withinPeriod(marker, periodThreshold));
    representativePhotos["large"]!.removeWhere((marker) => !withinPeriod(marker, periodThreshold));
    representativePhotos["middle"]!.removeWhere((marker) => !withinPeriod(marker, periodThreshold));
    representativePhotos["small"]!.removeWhere((marker) => !withinPeriod(marker, periodThreshold));
    _updateAllMarker();
  }

  Future<void> updateAllMarkersByTag(List<String> tags) async {
    currentPictoMarkers.removeWhere((marker) => !tags.contains(marker.photo.tag));
    aroundPhotos.removeWhere((marker) => !tags.contains(marker.photo.tag));
    representativePhotos["large"]?.removeWhere((marker) => !tags.contains(marker.photo.tag));
    representativePhotos["middle"]?.removeWhere((marker) => !tags.contains(marker.photo.tag));
    representativePhotos["small"]?.removeWhere((marker) => !tags.contains(marker.photo.tag));
    _updateAllMarker();
  }

  Future<void> updateAllMarkersBySort() async {
    _updateAllMarker();
  }

  // 사용자 위치 마커 생성
  Future<Marker> _buildUserMarker() async {
    return Marker(
        markerId: const MarkerId("user"),
        position: LatLng(currentLat.value, currentLng.value),
        icon: await MarkerWidget(type: PictoMarkerType.userPos).toBitmapDescriptor(
          logicalSize: const Size(150, 150),
          imageSize: const Size(150, 150),
        ),
        onTap: () {
          customInfoWindowController.addInfoWindow!(
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 25,
                  child: FloatingActionButton(
                    backgroundColor: AppConfig.mainColor,
                    heroTag: "Pos info",
                    onPressed: () {},
                    child: Text(
                      '현재 위치',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            LatLng(currentLat.value, currentLng.value),
          );
        },
        // 사영자 지정 커스텀 텝 구동, infoWindow 는 사용못함.
        consumeTapEvents: true);
  }

  void _loadRepresentative(String downloadType) async {
    Set<PictoMarker> pictoMarkers = await _converter.getRepresentativePhotos(1, currentStep);
    representativePhotos[currentStep]?.addAll(pictoMarkers);
    // print("[INFO]...? ${representativePhotos[currentStep]!}");
    for (PictoMarker pictoMarker in representativePhotos[currentStep]!) {
      if (_isPointInsideBounds(LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng), bounds)) {
        pictoMarker.imageData ??=
            await PhotoStoreHandler().downloadPhoto(pictoMarker.photo.photoId);
        currentPictoMarkers.add(pictoMarker);
        currentMarkers.add(await pictoMarker.toGoogleMarker());
      }
      if (currentStep != downloadType) return;
    }
  }

  void _loadAround(String downloadType) async {
    Set<PictoMarker> pictoMarkers = await _converter.getAroundPhotos();
    aroundPhotos.addAll(pictoMarkers);
    for (PictoMarker pictoMarker in aroundPhotos) {
      if (_isPointInsideBounds(LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng), bounds)) {
        pictoMarker.imageData ??=
            await PhotoStoreHandler().downloadPhoto(pictoMarker.photo.photoId);
        currentPictoMarkers.add(pictoMarker);
        currentMarkers.add(await pictoMarker.toGoogleMarker());
      }
      if (currentStep != downloadType) return;
    }
  }

  void _loadMyPhotos() async {
    myPhotos.forEach((pictoMarker) async {
      currentPictoMarkers.add(pictoMarker);
      currentMarkers.add(await pictoMarker.toGoogleMarker());
    });
  }

  void _loadFolder(String downloadType) async {}

  // 화면에 내 위치가 잡혀있는지 아닌지 검사
  bool _isPointInsideBounds(LatLng point, LatLngBounds bounds) {
    return bounds.southwest.latitude <= point.latitude &&
        bounds.northeast.latitude >= point.latitude &&
        bounds.southwest.longitude <= point.longitude &&
        bounds.northeast.longitude >= point.longitude;
  }
}
