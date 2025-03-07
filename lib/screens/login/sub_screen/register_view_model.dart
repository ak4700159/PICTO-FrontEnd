import 'package:get/get.dart';

class RegisterViewModel extends GetxController{
  RxString email = "".obs;
  RxString name = "".obs;
  RxString emailCode = "".obs;
  RxString passwd = "".obs;
  RxString passwdCheck = "".obs;
  RxBool emailDuplicated = false.obs;
  RxBool passwdVisible = false.obs;

  Future<void> signup() async {

  }
}