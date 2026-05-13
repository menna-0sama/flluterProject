import 'package:dio/dio.dart';
import 'package:graduation/model/level_request_model.dart';
import 'package:graduation/network/dio_client.dart';

class LevelApi {

  static Future<void> setLevel(LevelRequestModel model) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Ai/set-level",
        data: model.toJson(),
      );

      print("✅ SET LEVEL STATUS: ${response.statusCode}");
      print("✅ SET LEVEL RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("❌ STATUS: ${e.response?.statusCode}");
      print("❌ BODY: ${e.response?.data}");
      print("❌ MESSAGE: ${e.message}");
      throw Exception("API Error");
    }
  }
}