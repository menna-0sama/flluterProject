import 'package:graduation/network/dio_client.dart';

class AdminTracksApi {

  // 🟢 GET ALL TRACKS
  static Future<List<dynamic>> getTracks() async {
    final response = await DioClient.dio.get("/api/Tracks");
    return response.data;
  }

  // 🟢 CREATE TRACK
  static Future<void> createTrack({
    required String name,
    required String description,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Tracks",
      data: {
        "name": name,
        "description": description,
      },
    );

    print("✅ CREATE TRACK: ${response.data}");
  }

  // 🟡 UPDATE TRACK
  static Future<void> updateTrack({
    required int id,
    required String name,
    required String description,
  }) async {
    final response = await DioClient.dio.put(
      "/api/Tracks/$id",
      data: {
        "name": name,
        "description": description,
      },
    );

    print("✏️ UPDATE TRACK: ${response.data}");
  }

  // 🔴 DELETE TRACK
  static Future<void> deleteTrack(int id) async {
    final response = await DioClient.dio.delete(
      "/api/Tracks/$id",
    );

    print("🗑 DELETE TRACK: ${response.data}");
  }
}