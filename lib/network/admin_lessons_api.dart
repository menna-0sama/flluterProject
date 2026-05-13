import 'package:graduation/network/dio_client.dart';

class AdminLessonsApi {

  static Future<List<dynamic>> getLessons(int courseId) async {
    final response =
    await DioClient.dio.get("/api/Lessons/course/$courseId");

    final data = response.data;

    if (data is List) return data;

    if (data is Map && data["data"] is List) {
      return data["data"];
    }

    return [];
  }

  static Future<void> createLesson({
    required String title,
    required String description,
    required String videoUrl,
    required int duration,
    required int order,
    required int courseId,
  }) async {
    await DioClient.dio.post(
      "/api/Lessons",
      data: {
        "title": title,
        "description": description,
        "videoUrl": videoUrl,
        "duration": duration,
        "order": order,
        "courseId": courseId,
      },
    );
  }

  static Future<void> updateLesson({
    required int id,
    required String title,
    required String description,
    required String videoUrl,
    required int duration,
    required int order,
    required int courseId,
  }) async {
    await DioClient.dio.put(
      "/api/Lessons/$id",
      data: {
        "title": title,
        "description": description,
        "videoUrl": videoUrl,
        "duration": duration,
        "order": order,
        "courseId": courseId,
      },
    );
  }

  static Future<void> deleteLesson(int id) async {
    await DioClient.dio.delete("/api/Lessons/$id");
  }
}