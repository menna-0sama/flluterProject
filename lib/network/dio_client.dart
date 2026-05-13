import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static String? accessToken;
  static String? refreshToken;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://81.17.102.211:5000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  static Future<void> init() async {
    await loadTokens();

    dio.interceptors.clear();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken != null && accessToken!.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $accessToken";
          }

          print("➡️ REQUEST: ${options.method} ${options.path}");
          print("🔐 TOKEN: $accessToken");

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && refreshToken != null) {
            print("🔄 Token expired → trying refresh");

            final newToken = await refreshTokenRequest();

            if (newToken != null) {
              final retryResponse = await dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    "Authorization": "Bearer $newToken",
                    "Content-Type": "application/json",
                  },
                ),
              );

              return handler.resolve(retryResponse);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  static bool isAdmin() {
    if (accessToken == null || accessToken!.isEmpty) return false;

    try {
      final parts = accessToken!.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);

      final role = data[
      "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];

      return role == "Admin";
    } catch (e) {
      print("❌ ROLE DECODE ERROR: $e");
      return false;
    }
  }

  static Future<void> saveTokens({
    required String token,
    required String refresh,
  }) async {
    accessToken = token;
    refreshToken = refresh;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
    await prefs.setString("refreshToken", refresh);

    print("✅ TOKENS SAVED");
  }

  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString("accessToken");
    refreshToken = prefs.getString("refreshToken");

    print("✅ TOKENS LOADED: $accessToken");
  }

  static Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");

    print("🗑 TOKENS CLEARED");
  }

  static Future<String?> refreshTokenRequest() async {
    try {
      final response = await dio.post(
        "/api/Auth/refresh",
        data: {
          "refreshToken": refreshToken,
        },
      );

      print("🔐 Refresh Response: ${response.data}");

      final data = response.data;

      if (data is Map && data["data"] != null) {
        final newAccessToken = data["data"]["token"];
        final newRefreshToken = data["data"]["refreshToken"];

        await saveTokens(
          token: newAccessToken,
          refresh: newRefreshToken,
        );

        return newAccessToken;
      }

      final newAccessToken = data["accessToken"] ?? data["token"];
      final newRefreshToken = data["refreshToken"] ?? refreshToken;

      if (newAccessToken != null && newRefreshToken != null) {
        await saveTokens(
          token: newAccessToken,
          refresh: newRefreshToken,
        );
      }

      return newAccessToken;
    } catch (e) {
      print("❌ Refresh failed: $e");
      return null;
    }
  }
}