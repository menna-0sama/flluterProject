import 'package:dio/dio.dart';
import 'package:graduation/network/dio_client.dart';

class PasswordApi {
  static Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Auth/forgot-password",
        data: {
          "email": email,
        },
      );

      print("FORGOT STATUS: ${response.statusCode}");
      print("FORGOT RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("FORGOT ERROR STATUS: ${e.response?.statusCode}");
      print("FORGOT ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to send reset code");
    }
  }

  static Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Auth/verify-reset-code",
        data: {
          "email": email,
          "code": code,
        },
      );

      print("VERIFY STATUS: ${response.statusCode}");
      print("VERIFY RESPONSE: ${response.data}");

      if (response.statusCode != 200) {
        throw Exception("Invalid code");
      }

      if (response.data is Map && response.data["success"] == false) {
        throw Exception("Invalid code");
      }
    } on DioException catch (e) {
      print("VERIFY ERROR STATUS: ${e.response?.statusCode}");
      print("VERIFY ERROR BODY: ${e.response?.data}");
      throw Exception("Invalid code");
    }
  }

  static Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Auth/reset-password",
        data: {
          "resetToken": resetToken,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );

      print("RESET STATUS: ${response.statusCode}");
      print("RESET RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("RESET ERROR STATUS: ${e.response?.statusCode}");
      print("RESET ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to reset password");
    }
  }
}