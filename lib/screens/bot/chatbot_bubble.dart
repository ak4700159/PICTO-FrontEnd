import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/utils/functions.dart';

class ChatbotBubble extends StatelessWidget {
  final ChatbotMsg msg;
  final chatbotViewModel = Get.find<ChatbotViewModel>();

  ChatbotBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return _getChatBubbleByStatus(context);
  }

  Widget _getChatBubbleByStatus(BuildContext context) {
    return switch (msg.status) {
      ChatbotStatus.sending => _getSendingWidget(context),
      ChatbotStatus.isMe => _getIsMeWidget(context),
      ChatbotStatus.analysis => _getAnalysisWidget(context),
      ChatbotStatus.intro => _getIntroWidget(context),
      ChatbotStatus.compare => _getCompareWidget(context),
      ChatbotStatus.recommend => _getRecommendWidget(context)
    };
  }

  // 텍스트 전송중일 때
  Widget _getSendingWidget(BuildContext context) {
    return Center(
      child: Text("sending..."),
    );
  }

  Widget _getIsMeWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 사진 있으면 사진 처리
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (msg.images.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: msg.images
                      .map((image) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: GestureDetector(
                                onTap: () {
                                  // 이게 문제 ... ?
                                  if (image.photoId != null) {
                                    chatbotViewModel.selectPhoto(image.photoId!, image.data);
                                  }
                                },
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Image.memory(
                                    image.data,
                                    fit: BoxFit.cover,
                                    cacheWidth: 300,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7, // 최대 너비 제한
                  ),
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Text(
                    overflow: TextOverflow.visible,
                    msg.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConfig.mainColor,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _getAnalysisWidget(BuildContext context) {
    return Center(
      child: Text("analysis..."),
    );
  }

  // 분석 프롬프트
  Widget _getIntroWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 픽토리 로고
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300, borderRadius: BorderRadius.circular(100)),
                  child: Image.asset(
                    'assets/images/pictory_color.png',
                    scale: 5,
                  ),
                ),
                Text(
                  "PICTORY",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                )
              ],
            ),
          ),
        ),
        // 픽토리 채팅 내용
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.images.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: msg.images
                        .map((image) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: GestureDetector(
                                  onTap: () {
                                    // 이게 문제
                                    if (image.photoId != null) {
                                      chatbotViewModel.selectPhoto(image.photoId!, image.data);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Image.memory(
                                      image.data,
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: msg.isMe ? Colors.grey : AppConfig.mainColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.visible,
                  maxLines: 99,
                ),
              ),
              // 채팅 날짜
              Text(
                formatDate(msg.sendDatetime).substring("0000-".length),
                style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "NotoSansKR"),
              )
            ],
          ),
        ),
      ],
    );
  }

  // 분석
  Widget _getCompareWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      ],
    );
  }

  Widget _getRecommendWidget(BuildContext context) {
    return Center(
      child: Text("recommend..."),
    );
  }
}
