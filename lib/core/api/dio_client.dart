import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio()
    ..options = BaseOptions(
      baseUrl: 'https://dev.tito.lat/',
      connectTimeout: Duration(milliseconds: 20000), // 변경: int -> Duration
      receiveTimeout: Duration(milliseconds: 20000), // 변경: int -> Duration
    )
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 여기서 토큰을 추가합니다.
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print("Request: ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response: ${response.statusCode} ${response.data}");
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        // 에러 메시지와 함께 응답 본문을 출력
        print("Error: ${e.message}");
        if (e.response != null) {
          print("Response Body: ${e.response?.data}");
        } else {
          print("No response body available");
        }
        return handler.next(e);
      },
    ));

  static Dio get dio => _dio;

  static String? _accessToken;

  static Future<void> setToken(String token) async {
    _accessToken = token;
  }

  static Future<String?> _getToken() async {
    // 여기서 저장된 토큰을 반환합니다.
    return _accessToken;
  }
}
