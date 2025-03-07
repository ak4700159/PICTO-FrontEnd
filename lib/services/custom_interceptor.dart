import 'package:dio/dio.dart';

// 인터넵터를 등록하여 디버깅
class CustomInterceptor extends Interceptor{
  CustomInterceptor();
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQUEST] ${options.method}:${options.uri}\n');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RESPONSE] ${response.requestOptions.method}:${response.requestOptions.uri}\n');
    print('[RESPONSE] ${response.data}\n');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[ERROR] ${err.requestOptions.uri}    [Status code]${err.response?.statusCode}\n');
    super.onError(err, handler);
  }
}