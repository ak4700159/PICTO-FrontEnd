import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';

class ChatbotBubble extends StatelessWidget {
  final ChatbotMsg msg;
  final ChatbotMsg? preMsg;
  final chatbotViewModel = Get.find<ChatbotViewModel>();
  final promptBetweenHeight = 35.0;

  ChatbotBubble({super.key, required this.msg, required this.preMsg});

  @override
  Widget build(BuildContext context) {
    return _getChatBubbleByStatus(context);
  }

  Widget _getChatBubbleByStatus(BuildContext context) {
    return switch (msg.status) {
      ChatbotStatus.sending => _getSendingWidget(context),
      ChatbotStatus.isMe => _getIsMeWidget(context),
      ChatbotStatus.analysis => _getAnalysisWidget(context),
      ChatbotStatus.intro => _getIntroWidget(context, msg.content),
      ChatbotStatus.compare => _getCompareWidget(context),
      ChatbotStatus.recommend => _getRecommendWidget(context)
    };
  }

  // 텍스트 전송중일 때
  Widget _getSendingWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.1,
          child: Column(
            children: [
              AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FadeAnimatedText(
                    "픽토리가 채팅을 읽고 있어요!",
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 내가 보낸 채팅
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
                                  if (image.photoId != null) {
                                    chatbotViewModel.selectOtherPhoto(image.photoId!, image.data);
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
                      fontWeight: FontWeight.w300,
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

  // 분석 프롬프트
  Widget _getAnalysisWidget(BuildContext context) {
    if (!msg.content.contains("=== 촬영 가이드라인 ===")) {
      return _getIntroWidget(context, "프롬프트를 다시 작성해주세요");
    }
    String analysisMsg = msg.content.substring(0, msg.content.indexOf("=== 촬영 가이드라인 ===") - 2);
    String guideMsg = msg.content
        .substring(msg.content.indexOf("=== 촬영 가이드라인 ===") + "=== 촬영 가이드라인 ===".length + 1);
    // 줄 단위로 나누고 상위 4줄 제거
    List<String> lines = guideMsg.split('\n');
    if (lines.length > 4) {
      lines = lines.sublist(4); // 상위 4줄 제거
    } else {
      lines = []; // 전체가 4줄 이하라면 빈 리스트
    }
    // 다시 문자열로 합치기
    String trimmedGuideMsg = lines.join('\n');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: _getPictory(),
        ),
        Expanded(
          flex: 8,
          child: Column(
            children: [
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
                child: Column(
                  children: [
                    Text(
                      analysisMsg,
                      style: TextStyle(
                        wordSpacing: 2,
                        letterSpacing: 0.5,
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w300,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 99,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        titlePadding: EdgeInsets.all(10),
                        contentPadding: EdgeInsets.only(
                          bottom: 25,
                          left: 18,
                          right: 18,
                        ),
                        backgroundColor: Colors.white,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.photo_album),
                            const Text(
                              '가이드라인',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(Icons.cancel_outlined)),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            trimmedGuideMsg,
                            style: TextStyle(
                              wordSpacing: 2,
                              letterSpacing: 0.5,
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shadowColor: Colors.grey,
                    elevation: 2,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "가이드라인 보기",
                    style: TextStyle(
                      wordSpacing: 2,
                      letterSpacing: 0.5,
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: promptBetweenHeight),
            ],
          ),
        ),
      ],
    );
  }

  // 기본 프롬프트
  Widget _getIntroWidget(BuildContext context, String prompt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 픽토리 로고
        Expanded(
          flex: 2,
          child: _getPictory(),
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
                                      chatbotViewModel.selectOtherPhoto(image.photoId!, image.data);
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
                    wordSpacing: 2,
                    letterSpacing: 0.5,
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.visible,
                  maxLines: 99,
                ),
              ),
              SizedBox(height: promptBetweenHeight),
            ],
          ),
        ),
      ],
    );
  }

  // 비교 프롬프트
  Widget _getCompareWidget(BuildContext context) {
    List<String> blocks = msg.content.split('\n\n');
    if (blocks.length < 3) {
      return _getIntroWidget(context, "프롬프트를 다시 작성해주세요");
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: _getPictory(),
        ),
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getCompareWidgetList(context),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConfig.mainColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Text(
                  _trimBlock(blocks[2]),
                  style: TextStyle(
                    wordSpacing: 2,
                    letterSpacing: 0.5,
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.visible,
                  maxLines: 99,
                ),
              ),
              SizedBox(height: promptBetweenHeight),
            ],
          ),
        ),
      ],
    );
  }

  // 사진 추천 프롬프트
  Widget _getRecommendWidget(BuildContext context) {
    List<Widget> result = [];
    result.add(_getPictory());
    result.addAll(msg.images
        .map((image) => Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTap: () {
                        // 이게 문제
                        if (image.photoId != null) {
                          chatbotViewModel.selectOtherPhoto(image.photoId!, image.data);
                        }
                      },
                      child: SizedBox(
                        width: context.mediaQuery.size.width * 0.8,
                        height: context.mediaQuery.size.width * 0.8,
                        child: Image.memory(
                          image.data,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.8,
                    child: Text(
                      image.content ?? "전달 안됨",
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(height: promptBetweenHeight),
                ],
              ),
            ))
        .toList());
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: result,
      ),
    );
  }

  // 블록에서 첫 줄 제거 함수
  String _trimBlock(String block) {
    List<String> lines = block.trim().split('\n');
    if (lines.length <= 1) return ''; // 내용이 없다면 빈 문자열
    return lines.sublist(1).join('\n'); // 첫 줄 제외하고 다시 합침
  }

  // 필토리 로고
  Widget _getPictory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: Colors.grey.shade100, borderRadius: BorderRadius.circular(100)),
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
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getCompareWidgetList(BuildContext context) {
    List<String> blocks = msg.content.split('\n\n');
    String firstImage = _trimBlock(blocks[0]);
    String secondImage = _trimBlock(blocks[1]);
    List<Widget> resultWidgets = preMsg!.images
        .map(
          (image) => Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () {
                      chatbotViewModel.selectMyPhoto(image.data);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          // BoxShadow(offset: Offset(3, 3), color: Colors.grey, blurRadius: 20, spreadRadius: 20),
                        ],
                      ),
                      width: context.mediaQuery.size.width * 0.6,
                      height: context.mediaQuery.size.width * 0.6,
                      child: Image.memory(
                        image.data,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (preMsg!.images.indexOf(image) == 0)
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          firstImage,
                          style: TextStyle(
                            wordSpacing: 2,
                            letterSpacing: 0.5,
                            fontSize: 12,
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (preMsg!.images.indexOf(image) == 1)
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          secondImage,
                          style: TextStyle(
                            wordSpacing: 2,
                            letterSpacing: 0.5,
                            fontSize: 12,
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .toList();
    resultWidgets.insert(
        1,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: context.mediaQuery.size.width * 0.25,
              ),
              Icon(
                Icons.compare_arrows,
                color: Colors.red,
                size: 40,
              ),
              // Text(
              //   "   V  S  ",
              //   style: TextStyle(
              //     fontSize: 20,
              //     color: Colors.red,
              //     fontFamily: "NotoSansKR",
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        ));
    return resultWidgets;
  }
}
