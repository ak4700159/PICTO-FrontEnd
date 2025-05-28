import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../map/google_map/google_map_view_model.dart';

class RegisterViewModel extends GetxController{
  RxString email = "".obs;
  RxString name = "".obs;
  RxString accountName = "".obs;
  RxString passwd = "".obs;
  RxString passwdCheck = "".obs;
  RxString registerMsg = "회원 가입".obs;
  RxString emailDuplicatedMsg = "중복 검사".obs;
  RxBool isPasswordVisible = true.obs;

  void validateEmail() async {
    try{
      await UserManagerApi().duplicatedEmail(email.value);
      showPositivePopup("사용 가능한 메일입니다.");
      emailDuplicatedMsg.value = "사용 가능";
    } on DioException catch(e) {
      print("[ERROR]duplicate error");
      showErrorPopup("다시 중복 검사해주세요");
      // emailDuplicatedMsg.value = "다시 검사해주세요";
    }
  }

  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signup() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      UserManagerApi().signup(
          newUser: User(name: name.value, password: passwd.value, email: email.value, accountName: accountName.value),
          lat: googleMapViewModel.currentLat.value,
          lng: googleMapViewModel.currentLng.value);
    } on DioException catch(e) {
      if(e.response?.statusCode == 406) {
        registerMsg.value = "네트워크 오류";
        print("[ERROR]${e.message}");
      }
    }
  }
}