import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_view_model.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registerController = Get.put<RegisterViewModel>(RegisterViewModel());

    return Scaffold(
      body: Center(
        child: Text('/register_screen'),
      ),
    );
  }
}
