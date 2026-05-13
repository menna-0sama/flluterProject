import 'package:dio/dio.dart';
import 'package:graduation/model/progress_model.dart';
import 'package:graduation/network/dio_client.dart';

class ProgressApi {
  static Future<int> getTrackProgress(int trackId) async {
    try {
      final response = await DioClient.dio.get("/api/Progress/track/$trackId");

      print("TRACK PROGRESS STATUS: ${response.statusCode}");
      print("TRACK PROGRESS RESPONSE: ${response.data}");

      final data = response.data;

      if (data is Map && data["data"] != null) {
        return data["data"] ?? 0;
      }

      if (data is Map && data["progress"] != null) {
        return data["progress"] ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      print("TRACK PROGRESS ERROR STATUS: ${e.response?.statusCode}");
      print("TRACK PROGRESS ERROR BODY: ${e.response?.data}");
      return 0;
    }
  }

  static Future<int> getCourseProgress(int courseId) async {
    try {
      final response = await DioClient.dio.get("/api/Progress/course/$courseId");

      print("COURSE PROGRESS STATUS: ${response.statusCode}");
      print("COURSE PROGRESS RESPONSE: ${response.data}");

      final data = response.data;

      if (data is Map && data["progress"] != null) {
        return data["progress"] ?? 0;
      }

      if (data is Map && data["data"] != null) {
        return data["data"] ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      print("COURSE PROGRESS ERROR STATUS: ${e.response?.statusCode}");
      print("COURSE PROGRESS ERROR BODY: ${e.response?.data}");
      return 0;
    }
  }

  static Future<List<CourseProgressItem>> getCoursesWithProgress(
      int trackId,
      ) async {
    try {
      final response = await DioClient.dio.get("/api/Courses/track/$trackId");

      print("TRACK COURSES STATUS: ${response.statusCode}");
      print("TRACK COURSES RESPONSE: ${response.data}");

      final data = response.data;
      List coursesJson = [];

      if (data is Map && data["data"] is List) {
        coursesJson = data["data"];
      } else if (data is List) {
        coursesJson = data;
      }

      final List<CourseProgressItem> result = [];

      for (final item in coursesJson) {
        if (item is Map<String, dynamic>) {
          final courseId = item["id"] ?? 0;
          final progress = await getCourseProgress(courseId);

          result.add(
            CourseProgressItem(
              id: courseId,
              title: item["title"] ?? item["name"] ?? "",
              description: item["description"] ?? "",
              progress: progress,
            ),
          );
        }
      }

      return result;
    } on DioException catch (e) {
      print("COURSES ERROR STATUS: ${e.response?.statusCode}");
      print("COURSES ERROR BODY: ${e.response?.data}");
      return [];
    }
  }

  static Future<void> completeLesson({
    required int lessonId,
  }) async {
    try {
      print("✅ COMPLETE LESSON ID SENT: $lessonId");

      final response = await DioClient.dio.post(
        "/api/Progress/complete",
        queryParameters: {
          "lessonId": lessonId,
        },
      );

      print("COMPLETE STATUS: ${response.statusCode}");
      print("COMPLETE RESPONSE: ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Complete lesson failed: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ COMPLETE LESSON ID FAILED: $lessonId");
      print("COMPLETE ERROR STATUS: ${e.response?.statusCode}");
      print("COMPLETE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to complete lesson");
    } catch (e) {
      print("❌ COMPLETE LESSON GENERAL ERROR: $e");
      throw Exception("Failed to complete lesson");
    }
  }
}