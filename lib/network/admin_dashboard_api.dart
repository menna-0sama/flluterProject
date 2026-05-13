import 'package:graduation/model/track_stats_model.dart';
import 'dio_client.dart';

class AdminDashboardApi {
  static Future<List<TrackStatsModel>> getTrackStats() async {
    final response = await DioClient.dio.get(
      "/api/Admin/track-stats",
    );

    final data = response.data as List;

    return data.map((e) => TrackStatsModel.fromJson(e)).toList();
  }
}
