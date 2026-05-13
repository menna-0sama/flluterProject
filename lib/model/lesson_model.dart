
class LessonModel {
  final int id;
  final String title;
  final String description;

  final String videoUrl;
  final String videoUrl2;
  final String videoUrl3;

  final String articleUrl;

  final int duration;
  final int order;
  final int courseId;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.videoUrl2,
    required this.videoUrl3,
    required this.articleUrl,
    required this.duration,
    required this.order,
    required this.courseId,
  });

  List<String> get videos {
    return [
      videoUrl,
      videoUrl2,
      videoUrl3,
    ].where(
          (url) =>
      url.trim().isNotEmpty &&
          url.trim().toLowerCase() != "null",
    ).toList();
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json["id"] ?? 0,

      title:
      json["title"]?.toString() ??
          json["name"]?.toString() ??
          "",

      description:
      json["description"]?.toString() ?? "",

      videoUrl:
      json["videoUrl"]?.toString() ?? "",

      videoUrl2:
      json["videoUrl2"]?.toString() ?? "",

      videoUrl3:
      json["videoUrl3"]?.toString() ?? "",

      articleUrl:
      json["articleUrl"]?.toString() ??
          json["articleURL"]?.toString() ??
          "",

      duration: json["duration"] ?? 0,

      order: json["order"] ?? 0,

      courseId: json["courseId"] ?? 0,
    );
  }
}