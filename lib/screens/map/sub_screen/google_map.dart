import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map_view_model.dart';

import 'google_map_view_model.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    return GoogleMap(
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: googleMapViewModel.initCameraPos,
      onMapCreated: googleMapViewModel.setController,
      style: googleMapViewModel.mapStyleString,
    );
  }
}
