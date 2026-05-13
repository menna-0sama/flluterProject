import 'package:dio/dio.dart';
import 'package:graduation/model/ai_exam_model.dart';
import 'package:graduation/network/dio_client.dart';

class AiExamApi {
  static Future<AiExamResponse> startExam(String trackName) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Ai/exam/start",
        data: {
          "track": trackName.toLowerCase().trim(),
        },
      );

      print("START EXAM STATUS: ${response.statusCode}");
      print("START EXAM RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return AiExamResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception("Failed to start exam");
    } on DioException catch (e) {
      print("START EXAM ERROR STATUS: ${e.response?.statusCode}");
      print("START EXAM ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to start exam");
    } catch (e) {
      print("START EXAM UNKNOWN ERROR: $e");
      throw Exception("Failed to start exam");
    }
  }

  static Future<AiExamResponse> sendAnswer({
    required String sessionId,
    required String studentAnswer,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/api/Ai/exam/answer",
        data: {
          "sessionId": sessionId,
          "studentAnswer": studentAnswer.trim(),
        },
      );

      print("ANSWER STATUS: ${response.statusCode}");
      print("ANSWER RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return AiExamResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception("Failed to send answer");
    } on DioException catch (e) {
      print("ANSWER ERROR STATUS: ${e.response?.statusCode}");
      print("ANSWER ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to send answer");
    } catch (e) {
      print("ANSWER UNKNOWN ERROR: $e");
      throw Exception("Failed to send answer");
    }
  }
}