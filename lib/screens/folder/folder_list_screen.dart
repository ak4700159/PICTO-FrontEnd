import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';

import '../../config/app_config.dart';
import '../../models/folder.dart';
import '../../services/user_manager_service/user_api.dart';
import '../profile/profile_view_model.dart';

class FolderListScreen extends StatelessWidget {
  FolderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Get.find<ProfileViewModel>();
    final folderViewModel = Get.find<FolderViewModel>();
    return Scaffold(
      drawer: _getDrawer(context),
      appBar: AppBar(
        // shape: BeveledRectangleBorder(side: BorderSide(width: 0.5)),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${profileViewModel.accountName.value}의 폴더 목록",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // _getDropBox(context),
          // 드롭박스 버튼 추가
          // 폴더 생성 , 삭제 , 폴더 초대 확인(수락 및 거절)
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: folderViewModel.folders.keys.length,
        itemBuilder: (context, index) {
          return _getFolderWidget(folderViewModel.folders.keys.toList()[index]);
        },
      ),
    );
  }

  Widget _getDrawer(BuildContext context) {
    List<String> items = ["폴더 생성", "폴더 삭제", "초대 알림 확인", "초대 알림 전송"];
    return ListView.builder(
      itemBuilder: (context, idx) {
        return ListTile(title: Text(items[idx]));
      },
      itemCount: items.length,
    );
  }

  Widget _getFolderWidget(Folder folder) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              // 폴더 사진 화면 이동
              final folderViewModel = Get.find<FolderViewModel>();
              folderViewModel.changeFolder(folderId: folder.folderId);
              folderViewModel.changeSocket();
              Get.toNamed('/folder', arguments: {
                "folderId": folder.folderId,
              });
            },
            icon: Icon(
              Icons.folder,
              color: folder.generatorId == UserManagerApi().ownerId
                  ? AppConfig.mainColor
                  : Colors.white,
              weight: 1,
              size: 60,
            ),
          ),
          Text(
            folder.name,
            style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _getDropBox(BuildContext context) {
    List<String> items = ["폴더 생성", "폴더 삭제", "초대 알림 확인", "초대 알림 전송"];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          // 메뉴 아이템 생성
          items: items
              .map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ))
              .toList(),
          hint: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("선택"),
              Icon(Icons.arrow_drop_down_circle_outlined),
            ],
          ),
          onChanged: (val) {},
          // 클릭 시 이벤트
          // onChanged:
          //     field == "sort" ? selectionViewModel.changeSort : selectionViewModel.changePeriod,
          // 버튼 스타일
          buttonStyleData: ButtonStyleData(
            width: context.mediaQuery.size.height * 0.18,
            height: context.mediaQuery.size.height * 0.05,
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              color: AppConfig.backgroundColor,
              // borderRadius: BorderRadius.circular(40),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
              ],
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: AppConfig.backgroundColor,
              // borderRadius: BorderRadius.circular(10),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
              ],
            ),
          ),
          iconStyleData: IconStyleData(iconSize: 0.0),
          alignment: AlignmentDirectional.center,
        ),
      ),
    );
  }
}
