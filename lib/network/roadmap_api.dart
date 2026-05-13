import 'package:dio/dio.dart';
import 'package:graduation/model/roadmap_model.dart';
import 'package:graduation/network/dio_client.dart';

class RoadmapApi {
  static Future<RoadmapModel> getRoadmap({
    required String track,
    required String level,
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/api/Ai/roadmap",
        queryParameters: {
          "track": track.toLowerCase().trim(),
          "level": level.toLowerCase().trim(),
        },
      );

      print("ROADMAP STATUS: ${response.statusCode}");
      print("ROADMAP RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return RoadmapModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception("Failed to load roadmap");
    } on DioException catch (e) {
      print("ROADMAP ERROR STATUS: ${e.response?.statusCode}");
      print("ROADMAP ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load roadmap");
    }
  }
}