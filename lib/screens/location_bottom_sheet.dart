import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/functions.dart';

import '../utils/location.dart';

void showLocationBottomSheet(BuildContext context) {
  final googleMapViewModel = Get.find<GoogleMapViewModel>();
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(8),
        height: context.mediaQuery.size.height * 0.23,
        width: context.mediaQuery.size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.filter_frames, color: AppConfig.mainColor, size: 22,),
                  Text(
                    "  액자 저장하기",
                    // textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            TopBox(size: 0.01),
            FutureBuilder(
              future: fetchAddressFromKakao(
                  longitude: googleMapViewModel.currentLng.value,
                  latitude: googleMapViewModel.currentLat.value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "현재 위치 정보를 불러올 수 없습니다.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Icon(
                        //   Icons.pin_drop_rounded,
                        //   color: AppConfig.mainColor,
                        //   size: 20,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "정보 ${snapshot.data!}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatDateKorean(DateTime.now().millisecondsSinceEpoch),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          "현재 위치 저장",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.orangeAccent,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
