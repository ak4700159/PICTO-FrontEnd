import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/screens/profile/profile_modify_dialog.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/utils/popup.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/functions.dart';
import '../calendar/calendar_event_tile.dart';
import '../calendar/calendar_view_model.dart';
import 'latest_like_photos.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final profileViewModel = Get.find<ProfileViewModel>();
  final folderViewModel = Get.find<FolderViewModel>();
  final calendarViewModel = Get.find<CalendarViewModel>();
  final userConfig = Get.find<UserConfig>();

  @override
  Widget build(BuildContext context) {
    print("profile screen build");
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
                        color: AppConfig.mainColor,
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
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          padding: EdgeInsets.only(
                            bottom: 8,
                          ),
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
              height: MediaQuery.sizeOf(context).height * 0.05,
            ),
            // 사용자 프로필
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).width * 0.4,
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
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    "  좋아요 누른 사진",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: LatestLikePhotos(),
            ),

            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),

            // 마커 설정
            Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Row(
                children: [
                  Icon(
                    Icons.map,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    "  마커 노출 옵션",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _getCheckBoxSetting1(context),
                      _getCheckBoxSetting2(context),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    " 기타 옵션",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  TextButton(
                      onPressed: () {
                        showPasswordResetPopup(profileViewModel.email.value);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset),
                          Text(
                            "  비밀번호 재설정",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )),
                  TextButton(
                      onPressed: () {
                        showSelectionDialog(
                            context: context,
                            positiveEvent: () async {
                              final SharedPreferences preferences = await SharedPreferences.getInstance();
                              await preferences.clear();
                              Restart.restartApp();
                            },
                            negativeEvent: () {
                              Get.back();
                            },
                            positiveMsg: "네",
                            negativeMsg: "아니요",
                            content: "로그아웃 하시겠습니까?");
                      },
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          Text(
                            "  로그아웃",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )),
                  TextButton(
                      onPressed: () {
                        showSelectionDialog(
                            context: context,
                            positiveEvent: () async {
                              final SharedPreferences preferences = await SharedPreferences.getInstance();
                              await preferences.clear();
                              // Restart.restartApp();
                            },
                            negativeEvent: () {
                              Get.back();
                            },
                            positiveMsg: "네",
                            negativeMsg: "아니요",
                            content: "계정을 삭제하시겠습니까?");
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          Text(
                            "  계정삭제",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            // 위로 올릴 수 있도록
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
            ),
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
          errorBuilder: (context, object, trace) {
            return Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/images/picto_logo.png',
                  fit: BoxFit.cover,
                ));
          },
        ),
      );
    }

    return FutureBuilder(
      future: PhotoStoreApi().downloadPhoto(photoId: profileViewModel.profilePhotoId.value!, scale: 0.6),
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
            errorBuilder: (context, object, trace) {
              return Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/picto_logo.png',
                    fit: BoxFit.cover,
                  ));
            },
          ),
        );
      },
    );
  }

  void _showProfilePhotoBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.sizeOf(context).height * 0.8,
        width: MediaQuery.sizeOf(context).width,
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
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  child: Obx(
                    () => profileViewModel.selectedPictoMarker.value != null
                        ? TextButton(
                            onPressed: () {
                              profileViewModel.adaptProfile();
                            },
                            child: Text(
                              "적용하기",
                              style: TextStyle(
                                color: AppConfig.mainColor,
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
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.45,
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
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      height: MediaQuery.sizeOf(context).width * 0.5,
                      marker.imageData!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, object, trace) {
                        return Container(
                            color: Colors.white,
                            child: Image.asset(
                              'assets/images/picto_logo.png',
                              fit: BoxFit.cover,
                            ));
                      },
                    ),
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
                  Text(
                    "저장 일시 : ${formatDateKorean(marker.photo.updateDatetime!)}",
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
                          color: AppConfig.mainColor,
                          size: 30,
                        )
                      : Icon(
                          Icons.check_box_outline_blank,
                          color: Colors.grey.shade300,
                          size: 30,
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _getCheckBoxSetting1(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 5, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25)),
            border: BorderDirectional(
              end: BorderSide(color: Colors.grey, width: 0.5),
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "내 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Obx(() => Checkbox(
                      activeColor: AppConfig.mainColor,
                      value: userConfig.showMyPhotos.value,
                      onChanged: (checkValue) {
                        userConfig.toggleShowMyPhotos();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    )),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 5, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25)),
            border: BorderDirectional(
              end: BorderSide(color: Colors.grey, width: 0.5),
              top: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "주변 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => Checkbox(
                      activeColor: AppConfig.mainColor,
                      value: userConfig.showAroundPhotos.value,
                      onChanged: (checkValue) {
                        userConfig.toggleShowAroundPhotos();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getCheckBoxSetting2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 5, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(25)),
            border: BorderDirectional(
              start: BorderSide(color: Colors.grey, width: 0.5),
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "폴더 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => Checkbox(
                      activeColor: AppConfig.mainColor,
                      value: userConfig.showFolderPhotos.value,
                      onChanged: (checkValue) {
                        userConfig.toggleShowFolderPhotos();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    )),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 5, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
            border: BorderDirectional(
              start: BorderSide(color: Colors.grey, width: 0.5),
              top: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "대표 사진",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => Checkbox(
                      activeColor: AppConfig.mainColor,
                      value: userConfig.showRepresentativePhotos.value,
                      onChanged: (checkValue) {
                        userConfig.toggleShowRepresentativePhotos();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
