import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:picto_frontend/page_router.dart';
import 'package:picto_frontend/test_ground/ksm_test_screen.dart';

void main() {
  runApp(const Picto());
}

class Picto extends StatelessWidget {
  const Picto({super.key});

  @override
  Widget build(BuildContext context) {
    // 상단바는 보이게 하고 하단바는 감추기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return GetMaterialApp(
      title: 'PICTO APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: PageRouter.getPages(),
      initialRoute: '/test_ground',
      debugShowCheckedModeBanner: false,
    );
  }
}
