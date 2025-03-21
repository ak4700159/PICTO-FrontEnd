import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';

class RegisterViewModel extends GetxController{
  RxString email = "".obs;
  RxString name = "".obs;
  RxString passwd = "".obs;
  RxBool passwdCheck = false.obs;
  RxString registerStatus = "회원 가입".obs;
  RxString emailDuplicatedStatus = "중복 검사".obs;
  RxBool isPasswordVisible = false.obs;



  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signup() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    try {
      UserManagerHandler().signup(
          newUser: User(name: name.value, password: passwd.value, email: email.value),
          lat: googleMapViewModel.currentLat.value,
          lng: googleMapViewModel.currentLng.value);
    } on DioException catch(e) {
      registerStatus.value = "네트워크 오류";
      print("[ERROR]${e.message}");
    }
  }
}