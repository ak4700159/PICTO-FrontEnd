
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';

class FolderChatScreen extends StatelessWidget {
  const FolderChatScreen({super.key, required this.folderId});
  final int folderId;

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: const [
              ChatBubble(text: "안녕", isMe: false),
              ChatBubble(text: "앞으로 이 폴더에 우리 사진 저장하자", isMe: false),
              ChatBubble(text: "좋아!", isMe: true),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "메시지를 입력하세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.purple),
                onPressed: () {
                  // 메시지 전송
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
