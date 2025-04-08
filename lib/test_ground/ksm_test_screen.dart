import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_api.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chattingApi = ChattingApi();
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(onPressed: () {
                chattingApi.getMessagesByFolderAndSender(19, 1);
              })
            ],
          ),
        ],
      ),
    );
  }
}
