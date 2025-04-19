import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/sub_screen/invite/folder_invitation_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

import '../../../../models/notice.dart';
import '../../../../models/user.dart';
import '../../../../utils/functions.dart';

class FolderInvitationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<FolderInvitationViewModel>();
    viewModel.getInvitation();
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email,
              color: AppConfig.mainColor,
            ),
            Text(
              "  공유 폴더 초대 목록",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TopBox(size: 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PictoLogo(scale: 1.5, fontSize: 0),
            ],
          ),
          SizedBox(
            height: context.mediaQuery.size.height * 0.5,
            child: Obx(
              () => ListView.builder(
                itemCount: viewModel.notices.length,
                itemBuilder: (context, idx) {
                  return FutureBuilder(
                      future:
                          UserManagerApi().getUserByUserId(userId: viewModel.notices[idx].senderId),
                      builder: (context, snapshot) {
                        if (snapshot.data == null || snapshot.data == false) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text(
                            "사용자 정보를 불러올 수 없습니다.",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return _getNoticeTile(
                              context, idx, viewModel.notices[idx], snapshot.data!);
                        }
                      });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getNoticeTile(BuildContext context, int idx, Notice notice, User sender) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 8, // 흐림 정도
              spreadRadius: 1, // 그림자 확산 정도
              offset: Offset(2, 5), // 그림자 위치 조정
            )
          ]),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.person_pin_rounded,
              size: 30,
              color: getColorFromUserId(notice.noticeId),
            ),
          ),
          SizedBox(
            width: context.mediaQuery.size.width * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${sender.accountName}님 ${notice.folderName}로 초대하였습니다.",
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("전송 시간 : ${formatDate(notice.createDatetime)}")
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final viewModel = Get.find<FolderInvitationViewModel>();
              viewModel.eventInvitation(notice);
            },
            icon: Icon(
              Icons.check,
              size: 25,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              size: 25,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
