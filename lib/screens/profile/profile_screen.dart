import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/screens/profile/profile_modify_dialog.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';

import '../../utils/functions.dart';
import '../calendar/calendar_event_tile.dart';
import '../calendar/calendar_view_model.dart';
import '../calendar/picto_calendar.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final profileViewModel = Get.find<ProfileViewModel>();
  final folderViewModel = Get.find<FolderViewModel>();
  final calendarViewModel = Get.find<CalendarViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 수정하기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, right: 8),
                  child: TextButton(
                    onPressed: () {
                      // 사용자 프로필 수정 팝업 생성
                      showProfileModifyDialog(context);
                    },
                    child: Text(
                      "수정하기",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.green,
                        fontFamily: "NotoSansKR",
                      ),
                    ),
                  ),
                )
              ],
            ),
            // 사용자 계정 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Column(
                      children: [
                        Container(
                          width: context.mediaQuery.size.width * 0.8,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(179, 208, 250, 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  profileViewModel.accountName.value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: "NotoSansKR",
                                  ),
                                ),
                              ),
                              Text(
                                profileViewModel.email.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                  fontFamily: "NotoSansKR",
                                ),
                              ),
                              Text(
                                profileViewModel.intro.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontFamily: "NotoSansKR",
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ))
              ],
            ),
            SizedBox(
              height: context.mediaQuery.size.height * 0.05,
            ),
            // 사용자 프로필
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: context.mediaQuery.size.width * 0.4,
                      height: context.mediaQuery.size.width * 0.4,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Obx(() => _getProfileWidget()),
                    ),
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 0.5),
                          ],
                          borderRadius: BorderRadius.circular(100),
                          // border: Border.all(color: Colors.grey, width: 3)
                        ),
                        child: IconButton(
                          onPressed: () {
                            // 프로필 사진 수정 및 선택  화면
                            _showProfilePhotoBottomSheet(context);
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 30,
                            color: AppConfig.mainColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: context.mediaQuery.size.height * 0.02,
            ),

            SizedBox(
              height: context.mediaQuery.size.height * 0.05,
            ),
            // 캘린더
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(100)
                  boxShadow: [
                    BoxShadow(spreadRadius: 1, color: Colors.grey.shade100, blurRadius: 3, offset: Offset(0, 8)),
                  ]),
              child: PictoCalendar(),
            ),
            // 캘린더 선택 날짜에 따른 리스트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "선택한 날짜의 사진 목록",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            _getCalendarEventList(),
            // 위로 올릴 수 있도록
            SizedBox(
              height: context.mediaQuery.size.height * 0.3,
            )
          ],
        ),
      ),
    );
  }

  Widget _getProfileWidget() {
    // print("[INFO] get profile widget : ${profileViewModel.profilePhotoId.value}");
    if (profileViewModel.profilePhotoId.value == null) {
      return Icon(
        Icons.person,
        size: 100,
        color: Colors.grey.shade300,
      );
    }

    if (profileViewModel.profilePhoto.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.memory(
          profileViewModel.profilePhoto,
          fit: BoxFit.cover,
        ),
      );
    }

    return FutureBuilder(
      future: PhotoStoreApi().downloadPhoto(photoId: profileViewModel.profilePhotoId.value!, scale: 0.3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Icon(
            Icons.error,
            size: 100,
            color: Colors.red,
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void _showProfilePhotoBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: context.mediaQuery.size.height * 0.8,
        width: context.mediaQuery.size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: context.mediaQuery.size.height * 0.1,
                  child: Obx(
                    () => profileViewModel.selectedPictoMarker.value != null
                        ? TextButton(
                            onPressed: () {
                              profileViewModel.adaptProfile();
                            },
                            child: Text(
                              "적용하기",
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "대표 사진을 선택해주세요",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ),
                ),
                // 사진 리스트
              ],
            ),
            _getProfilePhotos(context),
          ],
        ),
      ),
    );
  }

  Widget _getProfilePhotos(BuildContext context) {
    return FutureBuilder(
      future: folderViewModel.getPictoMarkersByName(folderName: "default"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "데이터를 조회할 수 없습니다...",
              style: TextStyle(
                color: Colors.green,
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
        return SizedBox(
          width: context.mediaQuery.size.width,
          height: context.mediaQuery.size.height * 0.45,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 1개의 행에 항목을 3개씩
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, idx) {
              return _getProfilePhotoTile(snapshot.data![idx], context);
            },
          ),
        );
      },
    );
  }

  Widget _getProfilePhotoTile(PictoMarker marker, BuildContext context) {
    return GestureDetector(
      onTap: () {
        profileViewModel.selectedProfilePhoto(marker: marker);
      },
      child: Container(
        padding: EdgeInsets.all(3),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      width: context.mediaQuery.size.width * 0.5,
                      height: context.mediaQuery.size.width * 0.5,
                      marker.imageData!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "저장 일시 : ${formatDateKorean(marker.photo.updateDatetime!)}",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                        overflow: TextOverflow.fade),
                  ),
                  Text(
                    "장소 : ${marker.photo.location}",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                        overflow: TextOverflow.fade),
                  ),
                ],
              ),
            ),
            Obx(() => Positioned(
                  child: profileViewModel.selectedPictoMarker.value?.photo.photoId == marker.photo.photoId
                      ? Icon(
                          Icons.check_box,
                          color: Colors.green,
                          size: 30,
                        )
                      : Icon(
                          Icons.check_box_outline_blank,
                          color: Colors.grey,
                          size: 30,
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _getCalendarEventList() {
    return Obx(() => Column(
          children: calendarViewModel.selectedEvents.map((event) => CalendarEventTile(event: event)).toList(),
        ));
  }
}
