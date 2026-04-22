
import 'package:dio/dio.dart';

class DioClient {
  // 🔵 Base URL
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://81.17.102.211:5000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },

      // 🔥 أهم تعديل لحل مشكلة تحويل النجاح لـ Error
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  // 🔐 التوكنات
  static String? accessToken;
  static String? refreshToken;

  // 🚀 Init Interceptor
  static void init() {
    dio.interceptors.add(
      InterceptorsWrapper(
        // 🟢 قبل أي request
        onRequest: (options, handler) {
          if (accessToken != null) {
            options.headers["Authorization"] = "Bearer $accessToken";
          }

          return handler.next(options);
        },

        // 🔴 عند حدوث خطأ
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            print("🔄 Token expired → trying refresh");

            final newToken = await refreshTokenRequest();

            if (newToken != null) {
              accessToken = newToken;

              final retryResponse = await dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    "Authorization": "Bearer $newToken",
                  },
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );

              return handler.resolve(retryResponse);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // 🔥 Refresh Token
  static Future<String?> refreshTokenRequest() async {
    try {
      final response = await dio.post(
        "/api/Auth/refresh",
        data: {
          "refreshToken": refreshToken,
        },
      );

      print("🔐 Refresh Response: ${response.data}");

      final newToken = response.data["accessToken"];

      return newToken;
    } catch (e) {
      print("❌ Refresh failed: $e");
      return null;
    }
  }
}