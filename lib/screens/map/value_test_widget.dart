import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/services/session_scheduler_service/session_socket.dart';

import 'google_map/google_map_view_model.dart';

class ValueTestWidget extends StatelessWidget {
  const ValueTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    final sessionController = Get.find<SessionSocket>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Obx(
                () => Text(
                  '[zoom] ${googleMapViewModel.currentZoom.value.toStringAsFixed(3)} : ${googleMapViewModel.currentStep}',
                ),
              ),
            ),
            Obx(
              () => sessionController.connected.value
                  ? Icon(
                      Icons.wifi,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.wifi_off,
                      color: Colors.red,
                    ),
            ),
            Obx(() => Text('/ [isScreen] ${googleMapViewModel.isCurrentPosInScreen.value}'))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Obx(
                    () => Text(
                  '[screen center pos] lat : ${googleMapViewModel.currentScreenCenterLat.value.toStringAsFixed(3)}/ lng : ${googleMapViewModel.currentScreenCenterLng.value.toStringAsFixed(3)}',
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Obx(
                () => Text(
                  '[current pos] lat : ${googleMapViewModel.currentLat.value.toStringAsFixed(6)}/ lng : ${googleMapViewModel.currentLng.value.toStringAsFixed(6)}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
