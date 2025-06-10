import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../map/google_map/google_map_view_model.dart';

class RegisterViewModel extends GetxController {
  RxString email = "".obs;
  RxString name = "".obs;
  RxString accountName = "".obs;
  RxString passwd = "".obs;
  RxString passwdCheck = "".obs;
  RxString registerMsg = "회원 가입".obs;
  RxString emailDuplicatedMsg = "중복 검사".obs;
  RxBool isPasswordVisible = true.obs;
  // 중복 검사 시
  RxBool emailDuplicatedLoading = false.obs;
  // 이메일 인증 코드 인증 시
  RxBool emailAuthVerifyLoading = false.obs;
  // 이메일 인증 코드 전송 시
  RxBool emailAuthSendLoading = false.obs;
  // 회원 가입 요청 시
  RxBool registerLoading = false.obs;

  // 인증 코드
  RxString emailCode = "".obs;
  // 인증 코드 인증 완료 여부
  RxBool isEmailCodeAuth = false.obs;
  // 인증 코드 전송 여부
  RxBool isEmailCodeSend = false.obs;

  void validateEmail() async {
    try {
      emailDuplicatedLoading.value = true;
      await UserManagerApi().duplicatedEmail(email.value);
      showMsgPopup(msg: "사용 가능한 이메일입니다.", space: 0.4);
      emailDuplicatedMsg.value = "사용 가능";
    } on DioException catch (e) {
      showErrorPopup("이미 가입한 이메일입니다");
      // emailDuplicatedMsg.value = "재검사";
    }
    emailDuplicatedLoading.value = false;
  }

  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signup() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      UserManagerApi().signup(
        newUser: User(
          name: name.value,
          password: passwd.value,
          email: email.value,
          accountName: accountName.value,
        ),
        lat: googleMapViewModel.currentLat.value,
        lng: googleMapViewModel.currentLng.value,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 406) {
        registerMsg.value = "네트워크 오류";
        print("[ERROR]${e.message}");
      }
    }
  }

  void resetController() {
    email.value = "";
    name.value = "";
    accountName.value = "";
    passwd.value = "";
    passwdCheck.value = "";
    registerMsg.value = "회원 가입";
    emailDuplicatedMsg.value = "중복 검사";
    isPasswordVisible.value = true;
    isEmailCodeAuth.value = false;
    isEmailCodeSend.value = false;
    emailCode.value = "";

    emailAuthVerifyLoading.value = false;
    emailAuthSendLoading.value = false;
    emailDuplicatedLoading.value = false;
    print("[INFO] 초기화");
  }
}
