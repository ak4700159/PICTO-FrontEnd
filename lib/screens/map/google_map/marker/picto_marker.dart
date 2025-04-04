import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/photo/photo_view_model.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../../../models/photo.dart';
import '../google_map_view_model.dart';
import 'marker_widget.dart';

enum PictoMarkerType { userPhoto, folderPhoto, aroundPhoto, representativePhoto, userPos }

class PictoMarker {
  // 마커의 종류
  // 1. 내 사진
  // 2. 공유폴더에 올린 다른 사람 사진
  // 3. 지역 대표 사진
  // 4. 내 주변 사진

  PictoMarkerType type;

  // not null == 실제 이미지 데이터를 메모리에 적재
  Uint8List? imageData;
  Photo photo;

  PictoMarker({required this.photo, required this.type});


  factory PictoMarker.fromPhoto(Photo photo, PictoMarkerType type) {
    return PictoMarker(
      type: type,
      photo: photo,
    );
  }

  // 실제 이미지
  Future<Marker> toGoogleMarker() async {
    return Marker(
      position: LatLng(photo.lat, photo.lng),
      markerId: MarkerId(photo.photoId.toString()),
      icon: await MarkerWidget(
        imageData: imageData,
        type: type,
      ).toBitmapDescriptor(
        // 실제 마커에 띄워질 이미지는 imageSize 파라미터에 좌지우지 된다.
        logicalSize: const Size(300, 300),
        imageSize: const Size(500, 500),
      ),
      consumeTapEvents: true,
      onTap: () {
        GoogleMapViewModel googleMapViewModel = Get.find<GoogleMapViewModel>();
        PhotoViewModel photoViewModel = Get.find<PhotoViewModel>();
        googleMapViewModel.customInfoWindowController.addInfoWindow!(
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                  child: FloatingActionButton(
                    backgroundColor: AppConfig.mainColor,
                    onPressed: () async {
                      BoxFit fit = await photoViewModel.determineFit(imageData!);
                      Get.toNamed("/photo", arguments: {
                        "photo" : photo,
                        "data" : imageData,
                        "fit" : fit,
                      });
                    },
                    child: Text(
                      "상세 보기",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            LatLng(photo.lat, photo.lng));
      },
    );
  }

  // 사진 식별키로 구분
  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return (other is PictoMarker && other.photo.photoId == photo.photoId);
  }
}
