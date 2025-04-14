import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/notice.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

class FolderInvitationViewModel extends GetxController {
  RxList<Notice> notices = <Notice>[].obs;
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  RxList<User> selectedUsers = <User>[].obs;
  List<String> selectedEmail = [];

  void submitEmail(String? input) async {
    if (formKey.currentState?.validate() ?? false) {
      if (selectedEmail.contains(input)) {
        textController.text = "";
        return;
      }
      User? newUser = await UserManagerApi().getUserByEmail(email: input!);
      if (newUser != null && newUser.userId != UserManagerApi().ownerId) {
        selectedUsers.add(newUser);
        selectedEmail.add(input);
        formKey.currentState?.save();
      }
      textController.text = "";
    }
  }

  void deleteUser(int userId) {
    selectedUsers.removeWhere((u) => u.userId == userId);
  }

  void getInvitation() async {
    notices.clear();
    notices.addAll(
        await FolderManagerApi().getFolderInvitations(receiverId: UserManagerApi().ownerId!));
  }

  void eventInvitation(Notice target) async {
    bool isSuccess = await FolderManagerApi().eventFolderInvitation(
      isAccept: true,
      receiverId: UserManagerApi().ownerId!,
      noticeId: target.noticeId,
    );
    if (isSuccess) {
      Get.find<FolderViewModel>().resetFolder();
      showPositivePopup("공유 폴더를 추가하였습니다.");
    }
    notices.removeWhere((n) => n.noticeId == target.noticeId);
  }

  void sendInvitation() async {
    final folderViewModel = Get.find<FolderViewModel>();
    List<bool> isSuccess = [];
    for (User send in selectedUsers) {
      bool success = await FolderManagerApi().sendFolderInvitation(
          folderId: folderViewModel.currentFolder.value!.folderId,
          senderId: UserManagerApi().ownerId!,
          receiverId: send.userId!);
      isSuccess.add(success);
    }
    if (!isSuccess.contains(false)) {
      showPositivePopup("공유 초대하였습니다.");
    }
    selectedUsers.clear();
    selectedEmail.clear();
  }
}
