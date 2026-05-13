import 'package:dio/dio.dart';
import 'package:graduation/model/lesson_model.dart';
import 'package:graduation/network/dio_client.dart';

class LessonsApi {
  static Future<List<LessonModel>> getLessonsByCourse(int courseId) async {
    try {
      final response = await DioClient.dio.get(
        "/api/Lessons/course/$courseId",
      );

      print("LESSONS STATUS: ${response.statusCode}");
      print("LESSONS RESPONSE: ${response.data}");

      final data = response.data;

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map((item) => LessonModel.fromJson(item))
            .toList();
      }

      if (data is List) {
        return data.map((item) => LessonModel.fromJson(item)).toList();
      }

      return [];
    } on DioException catch (e) {
      print("LESSONS ERROR STATUS: ${e.response?.statusCode}");
      print("LESSONS ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load lessons");
    }
  }
}