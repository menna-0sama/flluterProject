class LevelStats {
  final String level;
  final int usersCount;

  LevelStats({
    required this.level,
    required this.usersCount,
  });

  factory LevelStats.fromJson(Map<String, dynamic> json) {
    return LevelStats(
      level: json["level"] ?? "",
      usersCount: json["usersCount"] ?? 0,
    );
  }
}

class TrackStatsModel {
  final int trackId;
  final String trackName;
  final int totalUsers;
  final List<LevelStats> levels;

  TrackStatsModel({
    required this.trackId,
    required this.trackName,
    required this.totalUsers,
    required this.levels,
  });

  factory TrackStatsModel.fromJson(Map<String, dynamic> json) {
    return TrackStatsModel(
      trackId: json["trackId"] ?? 0,
      trackName: json["trackName"] ?? "",
      totalUsers: json["totalUsers"] ?? 0,
      levels: (json["levels"] as List? ?? [])
          .map((e) => LevelStats.fromJson(e))
          .toList(),
    );
  }
}