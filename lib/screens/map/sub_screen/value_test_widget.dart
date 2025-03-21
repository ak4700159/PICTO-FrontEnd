import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';

class ValueTestWidget extends StatelessWidget {
  const ValueTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    final sessionController = Get.find<SessionSchedulerHandler>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(
          () => Text(
            '[zoom] ${googleMapViewModel.currentZoom.value}',
          ),
        ),
        Obx(
          () => Text(
            '[pos] lat : ${googleMapViewModel.currentLat.value}/ lng : ${googleMapViewModel.currentLng.value}',
          ),
        ),
        Obx(() => sessionController.connected.value
            ? Icon(
                Icons.wifi,
                color: Colors.green,
              )
            : Icon(
                Icons.wifi_off,
                color: Colors.red,
              )),
      ],
    );
  }
}
