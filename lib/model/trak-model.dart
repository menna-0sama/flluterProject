class TrackModel {
  final int id;
  final String name;
  final String description;

  TrackModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? json['trackId'] ?? 0,
      name: json['name'] ?? json['title'] ?? json['trackName'] ?? 'Track',
      description: json['description'] ??
          'Start learning this track and improve your skills.',
    );
  }
}