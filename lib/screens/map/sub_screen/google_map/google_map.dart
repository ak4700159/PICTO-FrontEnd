import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/top_box.dart';
import 'package:picto_frontend/screens/map/sub_screen/value_test_widget.dart';

import '../selection_bar.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: googleMapViewModel.currentCameraPos,
          onMapCreated: googleMapViewModel.setController,
          style: googleMapViewModel.mapStyleString,
          onCameraMove: googleMapViewModel.onCameraMove,
          markers: googleMapViewModel.returnMarkerAccordingToZoom(),
        ),
        Column(
          children: [
            TopBox(),
            SelectionBar(),
            ValueTestWidget(),
          ],
        ),
      ],
    );
  }
}
