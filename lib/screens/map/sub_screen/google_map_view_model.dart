import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapViewModel extends GetxController {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  RxDouble currentLat = 0.0.obs;
  RxDouble currentLng = 0.0.obs;
  late String mapStyleString;
  late CameraPosition initCameraPos;

  @override
  void onInit() {
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    // TODO: implement onInit
    super.onInit();
  }

  void setController(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller); // 최초 1회만 실행됨
    }

    // 스트림 연결 -> 위치 정보를
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
    initCameraPos = CameraPosition(
      target: LatLng(currentLat.value, currentLng.value),
      zoom: 14.4746,
    );
    print("[INFO] now location : ${currentLat.value}/${currentLng.value}\n");
  }
}
