import 'package:dio/dio.dart';
import 'package:graduation/model/track_chat_model.dart';
import 'package:graduation/network/dio_client.dart';

class TrackChatApi {
  static Future<List<TrackChatModel>> getMessages(int trackId) async {
    try {
      final response = await DioClient.dio.get(
        "/api/TrackChat/$trackId",
      );

      print("TRACK CHAT STATUS: ${response.statusCode}");
      print("TRACK CHAT RESPONSE: ${response.data}");

      final data = response.data;

      if (data is List) {
        return data
            .map((item) => TrackChatModel.fromJson(item))
            .toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map((item) => TrackChatModel.fromJson(item))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print("TRACK CHAT ERROR STATUS: ${e.response?.statusCode}");
      print("TRACK CHAT ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load track chat");
    }
  }

  static Future<void> sendMessage({
    required int trackId,
    required String content,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/api/TrackChat",
        data: {
          "trackId": trackId,
          "content": content,
        },
      );

      print("SEND CHAT STATUS: ${response.statusCode}");
      print("SEND CHAT RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("SEND CHAT ERROR STATUS: ${e.response?.statusCode}");
      print("SEND CHAT ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to send message");
    }
  }
}