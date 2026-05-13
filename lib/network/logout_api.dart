import 'package:dio/dio.dart';
import 'package:graduation/network/dio_client.dart';

class LogoutApi {
  static Future<void> logout() async {
    try {
      final response = await DioClient.dio.post("/api/Auth/logout");

      print("LOGOUT STATUS: ${response.statusCode}");
      print("LOGOUT RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("LOGOUT ERROR STATUS: ${e.response?.statusCode}");
      print("LOGOUT ERROR BODY: ${e.response?.data}");
    }
  }
}