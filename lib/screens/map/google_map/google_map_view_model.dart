import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/cluster/picto_cluster_item.dart';
import 'package:picto_frontend/services/session_scheduler_service/session_socket.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../models/folder.dart';
import '../../../utils/distance.dart';
import 'cluster/picto_cluster_manager.dart';
import 'marker/marker_converter.dart';
import 'marker/animated_marker_widget.dart';
import 'marker/picto_marker.dart';

class GoogleMapViewModel extends GetxController {
  // ChatGPT 방안 completer 사용하지 말고 GoogleMapController 직접 관리
  GoogleMapController? _googleMapController;
  RxDouble currentLat = 0.0.obs;
  RxDouble currentLng = 0.0.obs;
  RxDouble currentZoom = 0.0.obs;
  late LatLngBounds screenBounds;
  late LatLng currentScreenCenterLatLng;
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

  // 지도에 반영되는 주요 구성
  RxSet<PictoMarker> currentPictoMarkers = <PictoMarker>{}.obs;
  RxSet<Marker> currentMarkers = <Marker>{}.obs;
  RxSet<Circle> circles = <Circle>{}.obs;

  // 사용자 현재 위치 마커(small)
  late Marker userMarker;

  // 클러스터 매니저
  PictoClusterManager pictoCluster = PictoClusterManager();

  @override
  void onInit() async {
    // 지도 양식 로딩
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    // 사용자 마커 생성
    userMarker = await _buildUserMarker();
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
    // 몇 배율 변화까지 허용
    const double zoomThreshold = 0.5;
    // m 이동 기준
    const double centerDistanceThreshold = 500;
    pictoCluster.manager.onCameraMove(pos);
    customInfoWindowController.onCameraMove!();
    // 화면 줌 정보
    currentCameraPos = pos;
    currentZoom.value = pos.zoom;

    // 화면 중앙 정보 로딩
    try {
      screenBounds = await _googleMapController!.getVisibleRegion();
      currentScreenCenterLat.value =
          (screenBounds.northeast.latitude + screenBounds.southwest.latitude) / 2;
      currentScreenCenterLng.value =
          (screenBounds.northeast.longitude + screenBounds.southwest.longitude) / 2;
      final newLatLng = LatLng(currentScreenCenterLat.value, currentScreenCenterLng.value);
      final currentPos = LatLng(currentLat.value, currentLng.value);

      // small[2~7], middle[7~12], large[12~17]
      // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
      if (pos.zoom >= 2 && pos.zoom < 7) {
        currentStep = "large";
        isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, screenBounds);
        if ((currentZoom.value - pos.zoom).abs() > zoomThreshold ||
            distance(currentScreenCenterLatLng, newLatLng) > centerDistanceThreshold) {
          needUpdate = true;
        }
      } else if (pos.zoom >= 7 && pos.zoom < 12) {
        currentStep = "middle";
        isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, screenBounds);
        if ((currentZoom.value - pos.zoom).abs() > zoomThreshold ||
            distance(currentScreenCenterLatLng, newLatLng) > centerDistanceThreshold) {
          needUpdate = true;
        }
        // 화면 안에 있을 경우 주변 사진만 보여준다.
      } else {
        currentStep = "small";
        isCurrentPosInScreen.value = _isPointInsideBounds(currentPos, screenBounds);
        if ((currentZoom.value - pos.zoom).abs() > zoomThreshold ||
            distance(currentScreenCenterLatLng, newLatLng) > centerDistanceThreshold) {
          needUpdate = true;
        }
      }
    } catch (e) {
      print("[ERROR] acquired screen location fail ${e.toString()}");
    }
  }

  // 카메라 이동이 끝났을 때 호출
  void onCameraIdle() {
    if (needUpdate) {
      _updateAllMarker();
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
      pictoCluster.initClusterManager();
      _googleMapController = controller;
      customInfoWindowController.googleMapController = controller;
      LatLngBounds bounds = await controller.getVisibleRegion();
      currentScreenCenterLat.value = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      currentScreenCenterLng.value = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      pictoCluster.manager.setMapId(controller.mapId);
      pictoCluster.manager
          .setItems(currentPictoMarkers.map((p) => PictoItem(pictoMarker: p)).toList());
      Get.find<SessionSocket>().connectWebSocket();
    } catch (e) {
      print("[ERROR] : controller comfyui error");
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

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 허용해야 합니다.');
    }

    // print("[INFO] check!");
    // 최초 카메라 설정
    Position position = await Geolocator.getCurrentPosition();
    // print("[INFO] check2!");
    currentLat.value = position.latitude;
    currentLng.value = position.longitude;
    currentZoom.value = 14;
    currentCameraPos = CameraPosition(
      target: LatLng(currentLat.value, currentLng.value),
      zoom: 14,
    );
    currentScreenCenterLatLng = LatLng(position.latitude, position.longitude);
    // print("[INFO] now location : ${currentLat.value}/${currentLng.value}\n");

    // 현재 위치 주소를 구독하기
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        currentLat.value = position.latitude;
        currentLng.value = position.longitude;
        _updateComponent();
        print("[INFO] get current pos -> lat : ${currentLat.value} / lng : ${currentLng.value}");
      },
    );
  }

  // 사용자 위치 + 원  변경
  void _updateComponent() async {
    userMarker = await _buildUserMarker();
    // 마커 셋에서 이전 것 제거 후 다시 추가
    if (currentStep != "large") {
      currentMarkers.removeWhere((marker) => marker.markerId.value == "user");
      currentMarkers.add(userMarker);
    }
    circles.clear();
    circles.add(Circle(
      circleId: CircleId("user_area"),
      center: LatLng(currentLat.value, currentLng.value),
      radius: 5000,
      fillColor: Colors.transparent,
      strokeColor: AppConfig.mainColor,
      strokeWidth: 1,
    ));
  }

  // 전체 마커 업데이트 -> 해당 부분 최적화 가능
  Future<void> _updateAllMarker() async {
    currentPictoMarkers.clear();
    currentMarkers.clear();
    pictoCluster.manager.setItems([]);

    if (currentStep == "large") {
      // 지역 대표 사진만 로딩
      await _loadRepresentative(currentStep);
    } else if (currentStep == "middle") {
      // 지역 대표 사진 + 내 위치 + 폴더 사진 + 내 사진
      await _loadRepresentative(currentStep);
      // 확인해야됨
    } else {
      // (지역 대표 사진 OR 주변 사진) + 내 위치 + 폴더 사진 + 내 사진
      if (distance(currentScreenCenterLatLng, LatLng(currentLat.value, currentLng.value)) < 5000) {
        await _loadAround(currentStep);
      } else {
        await _loadRepresentative(currentStep);
      }
    }
    currentMarkers.add(userMarker);
    await _loadFolder(currentStep);
    // 위의 작업은 화면 정보(Zoom, 지도를 바라보고 있는 시점)를 바탕으로 마커 클스터링
    pictoCluster.manager
        .setItems(currentPictoMarkers.map((p) => PictoItem(pictoMarker: p)).toList());
  }

  // 보여지는 마커 필터에 따라 변경
  Future<void> updateAllMarkersByPeriod(String period) async {
    representativePhotos["large"]!.clear();
    representativePhotos["middle"]!.clear();
    representativePhotos["small"]!.clear();
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
        icon: await AnimatedMarkerWidget(type: PictoMarkerType.userPos).toBitmapDescriptor(
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

  Future<void> _loadRepresentative(String downloadType) async {
    final userConfig = Get.find<UserConfig>();
    List<PictoMarkerType> types = userConfig.getMarkerFilter();
    Set<PictoMarker> newMarkers = await _converter.getRepresentativePhotos(1, downloadType);
    representativePhotos[downloadType]?.addAll(newMarkers);
    for (PictoMarker pictoMarker in representativePhotos[downloadType]!) {
      if (_isPointInsideBounds(
          LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng), screenBounds)) {
        if (types.contains(pictoMarker.type)) {
          currentPictoMarkers.add(pictoMarker);
        }
      }
      if (currentStep != downloadType) return;
    }
  }

  Future<void> _loadAround(String downloadType) async {
    final userConfig = Get.find<UserConfig>();
    List<PictoMarkerType> types = userConfig.getMarkerFilter();
    Set<PictoMarker> newMarkers = await _converter.getAroundPhotos();
    aroundPhotos.addAll(newMarkers);
    for (PictoMarker pictoMarker in aroundPhotos) {
      if (_isPointInsideBounds(
          LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng), screenBounds)) {
        if (types.contains(pictoMarker.type)) {
          currentPictoMarkers.add(pictoMarker);
        }
      }
      if (currentStep != downloadType) return;
    }
  }

  Future<void> _loadFolder(String downloadType) async {
    final userConfig = Get.find<UserConfig>();
    List<PictoMarkerType> types = userConfig.getMarkerFilter();
    final folderViewModel = Get.find<FolderViewModel>();
    final newMarkers = <PictoMarker>{};
    for (Folder folder in folderViewModel.folders.values) {
      newMarkers.addAll(folder.markers);
    }
    folderPhotos.addAll(newMarkers);
    for (PictoMarker pictoMarker in newMarkers) {
      if (_isPointInsideBounds(
          LatLng(pictoMarker.photo.lat, pictoMarker.photo.lng), screenBounds)) {
        if (types.contains(pictoMarker.type)) {
          currentPictoMarkers.add(pictoMarker);
        }
      }
      if (currentStep != downloadType) return;
    }
  }

  // 화면에 내 위치가 잡혀있는지 아닌지 검사
  bool _isPointInsideBounds(LatLng point, LatLngBounds bounds) {
    return bounds.southwest.latitude <= point.latitude &&
        bounds.northeast.latitude >= point.latitude &&
        bounds.southwest.longitude <= point.longitude &&
        bounds.northeast.longitude >= point.longitude;
  }

  // 이미지 다시 다운로드 하기위함
  void resetMarker() {
    aroundPhotos.clear();
    representativePhotos["small"]?.clear();
    representativePhotos["middle"]?.clear();
    representativePhotos["large"]?.clear();
    myPhotos.clear();
    folderPhotos.clear();
    currentMarkers.clear();
    currentPictoMarkers.clear();

    final folderViewModel = Get.find<FolderViewModel>();
    folderViewModel.setZero();
  }
}
