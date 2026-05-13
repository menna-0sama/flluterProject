import 'package:dio/dio.dart';
import 'package:graduation/network/dio_client.dart';

class AdminCoursesApi {
  static Future<List<dynamic>> getCourses() async {
    final response = await DioClient.dio.get("/api/Courses");

    final data = response.data;

    if (data is List) return data;

    if (data is Map && data["data"] is List) {
      return data["data"];
    }

    return [];
  }

  static Future<void> createCourse({
    required String title,
    required String description,
    required int order,
    required int trackId,
  }) async {
    try {
      final body = {
        "title": title,
        "description": description,
        "order": order,
        "trackId": trackId,
      };

      print("CREATE COURSE BODY: $body");

      final response = await DioClient.dio.post(
        "/api/Courses",
        data: body,
      );

      print("CREATE COURSE STATUS: ${response.statusCode}");
      print("CREATE COURSE RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("CREATE COURSE ERROR STATUS: ${e.response?.statusCode}");
      print("CREATE COURSE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to create course");
    }
  }

  static Future<void> updateCourse({
    required int id,
    required String title,
    required String description,
    required int order,
    required int trackId,
  }) async {
    try {
      final body = {
        "title": title,
        "description": description,
        "order": order,
        "trackId": trackId,
      };

      print("UPDATE COURSE BODY: $body");

      final response = await DioClient.dio.put(
        "/api/Courses/$id",
        data: body,
      );

      print("UPDATE COURSE STATUS: ${response.statusCode}");
      print("UPDATE COURSE RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("UPDATE COURSE ERROR STATUS: ${e.response?.statusCode}");
      print("UPDATE COURSE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to update course");
    }
  }

  static Future<void> deleteCourse(int id) async {
    try {
      final response = await DioClient.dio.delete("/api/Courses/$id");

      print("DELETE COURSE STATUS: ${response.statusCode}");
      print("DELETE COURSE RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("DELETE COURSE ERROR STATUS: ${e.response?.statusCode}");
      print("DELETE COURSE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to delete course");
    }
  }
}