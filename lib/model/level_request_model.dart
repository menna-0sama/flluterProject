class LevelRequestModel {
  final int trackId;
  final String level;
  final String time;

  LevelRequestModel({
    required this.trackId,
    required this.level,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "trackId": trackId,
      "level": level,
      "time": time,
    };
  }
}