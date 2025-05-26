import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/sub_screen/invite/folder_invitation_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/get_widget.dart';
import 'package:picto_frontend/utils/validator.dart';

import '../../../../models/user.dart';
import '../../../../utils/functions.dart';

class FolderInvitationSendScreen extends StatelessWidget {
  const FolderInvitationSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<FolderInvitationViewModel>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send,
                color: AppConfig.mainColor,
                size: 30,
              ),
              Text(
                "  폴더 공유",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBox(size: 0.05),
              // 공유할 사용자 이메일 입력
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.8,
                    child: Form(
                      key: viewModel.formKey,
                      child: TextFormField(
                        controller: viewModel.textController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          errorMaxLines: 2,
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          labelStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          labelText: "공유할 사용자 이메일 입력",
                          hintText: "이메일 형식으로 적어주세요",
                          hintStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          fillColor: Colors.grey.shade300,
                          filled: true,
                        ),
                        validator: emailValidator,
                        // onSaved: viewModel.addEmail,
                        onFieldSubmitted: viewModel.submitEmail,
                      ),
                    ),
                  )
                ],
              ),
              TopBox(size: 0.02),
              SizedBox(
                height: context.mediaQuery.size.height * 0.5,
                child: Obx(
                  () => ListView.builder(
                    itemCount: viewModel.selectedUsers.length,
                    itemBuilder: (context, idx) {
                      return _getUserTile(context, idx, viewModel.selectedUsers[idx]);
                    },
                  ),
                ),
              ),
              TopBox(size: 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.7,
                    height: context.mediaQuery.size.height * 0.06,
                    child: FloatingActionButton(
                      onPressed: () {
                        viewModel.sendInvitation();
                      },
                      backgroundColor: AppConfig.mainColor,
                      child: Text(
                        "전송하기",
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getUserTile(BuildContext context, int idx, User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4, // 흐림 정도
                spreadRadius: 0.1, // 그림자 확산 정도
                offset: Offset(2, 3), // 그림자 위치 조정
              )
            ]),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getUserProfile(user: user, context: context, size: 0.14, scale : 0.2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.accountName}",
                  style: TextStyle(
                    fontFamily: "NotoSansKR",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${user.email}",
                  style: TextStyle(
                    fontFamily: "NotoSansKR",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                Get.find<FolderInvitationViewModel>().deleteUser(user.userId!);
              },
              icon: Icon(
                Icons.delete,
                size: 30,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
