import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';
import '../../models/chatting_msg.dart';

class ChattingApi{
  ChattingApi._();

  static final ChattingApi _handler = ChattingApi._();

  factory ChattingApi() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8085/chat";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )..interceptors.add(CustomInterceptor());


  // 채팅 히스토리 조회
  Future<List<ChatMsg>> getChatHistory({required int folderId}) async {
    final response = await dio.get('$baseUrl/history/$folderId');
    return (response.data as List)
        .map((json) => ChatMsg.fromJson(json))
        .toList();
  }

  // 폴더 ID로 채팅 조회
  Future<List<ChatMsg>> getMessagesByFolderId({required int folderId}) async {
    final response = await dio.get('$baseUrl/folder/$folderId');
    return (response.data as List)
        .map((json) => ChatMsg.fromJson(json))
        .toList();
  }

  // 발신자 ID로 채팅 조회
  Future<List<ChatMsg>> getMessagesBySenderId({required int senderId}) async {
    final response = await dio.get('$baseUrl/sender/$senderId');
    return (response.data as List)
        .map((json) => ChatMsg.fromJson(json))
        .toList();
  }

  // 폴더 + 발신자 ID로 채팅 조회
  Future<List<ChatMsg>> getMessagesByFolderAndSender(
      int folderId, int senderId) async {
    final response = await dio.get('$baseUrl/folder/$folderId/sender/$senderId');
    return (response.data as List)
        .map((json) => ChatMsg.fromJson(json))
        .toList();
  }
}