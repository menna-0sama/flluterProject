
import 'package:dio/dio.dart';
import 'package:graduation/model/trak-model.dart';
import 'package:graduation/network/dio_client.dart';

class TracksApi {

  static Future<List<TrackModel>> getTracks() async {
    try {
      final response = await DioClient.dio.get(
        "/api/Tracks",
      );

      print("TRACKS STATUS: ${response.statusCode}");
      print("TRACKS RESPONSE: ${response.data}");

      final data = response.data;

      if (data is List) {
        return data.map((e) => TrackModel.fromJson(e)).toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map((e) => TrackModel.fromJson(e))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print("TRACKS ERROR STATUS: ${e.response?.statusCode}");
      print("TRACKS ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load tracks");
    }
  }

  // ✅ دي الإضافة بس
  static Future<TrackModel?> getTrackById(int trackId) async {
    try {
      final response = await DioClient.dio.get(
        "/api/Tracks/$trackId",
      );

      print("TRACK BY ID STATUS: ${response.statusCode}");
      print("TRACK BY ID RESPONSE: ${response.data}");

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return TrackModel.fromJson(data);
      }

      if (data is Map && data["data"] is Map) {
        return TrackModel.fromJson(
          Map<String, dynamic>.from(data["data"]),
        );
      }

      return null;
    } on DioException catch (e) {
      print("TRACK BY ID ERROR STATUS: ${e.response?.statusCode}");
      print("TRACK BY ID ERROR BODY: ${e.response?.data}");
      return null;
    }
  }
}