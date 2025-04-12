import 'package:dropdown_button2/dropdown_button2.dart';
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

class AppBarMenuExample extends StatelessWidget {
  const AppBarMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 화면'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.purple),
            onSelected: (value) {
              switch (value) {
                case "create":
                  print("폴더 생성");
                  break;
                case "delete":
                  print("폴더 삭제");
                  break;
                case "notify":
                  print("초대 알림 확인");
                  break;
                case "send":
                  print("초대 알림 전송");
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "create", child: Text("폴더 생성")),
              const PopupMenuItem(value: "delete", child: Text("폴더 삭제")),
              const PopupMenuItem(value: "notify", child: Text("초대 알림 확인")),
              const PopupMenuItem(value: "send", child: Text("초대 알림 전송")),
            ],
          )
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(child: Text("내용")),
    );
  }
}
