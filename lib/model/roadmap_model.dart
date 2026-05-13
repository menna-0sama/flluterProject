class RoadmapLessonModel {
  final String lessonId;
  final String topic;
  final String subtopic;
  final String contentType;
  final String description;
  final List<String> videos;
  final String article;

  RoadmapLessonModel({
    required this.lessonId,
    required this.topic,
    required this.subtopic,
    required this.contentType,
    required this.description,
    required this.videos,
    required this.article,
  });

  factory RoadmapLessonModel.fromJson(Map<String, dynamic> json) {
    final resources = json["resources"] is Map
        ? Map<String, dynamic>.from(json["resources"])
        : <String, dynamic>{};

    final videosMap = resources["videos"] is Map
        ? Map<String, dynamic>.from(resources["videos"])
        : <String, dynamic>{};

    final List<String> videosList = videosMap.values
        .where((v) =>
    v != null &&
        v.toString().trim().isNotEmpty &&
        v.toString() != "null")
        .map((v) => v.toString())
        .toList();

    if (videosList.isEmpty &&
        resources["video"] != null &&
        resources["video"].toString().trim().isNotEmpty &&
        resources["video"].toString() != "null") {
      videosList.add(resources["video"].toString());
    }

    return RoadmapLessonModel(
      lessonId: json["lesson_id"]?.toString() ?? "",
      topic: json["topic"]?.toString() ?? "",
      subtopic: json["subtopic"]?.toString() ?? "",
      contentType: json["content_type"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      videos: videosList,
      article: resources["article"]?.toString() ?? "",
    );
  }
}

class RoadmapStepModel {
  final int step;
  final String topicId;
  final String mainTopic;
  final List<RoadmapLessonModel> lessons;

  RoadmapStepModel({
    required this.step,
    required this.topicId,
    required this.mainTopic,
    required this.lessons,
  });

  factory RoadmapStepModel.fromJson(Map<String, dynamic> json) {
    return RoadmapStepModel(
      step: json["step"] ?? 0,
      topicId: json["topic_id"]?.toString() ?? "",
      mainTopic: json["main_topic"]?.toString() ?? "",
      lessons: json["lessons"] is List
          ? (json["lessons"] as List)
          .map((e) => RoadmapLessonModel.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],
    );
  }
}

class RoadmapModel {
  final String track;
  final String level;
  final List<RoadmapStepModel> roadmap;

  RoadmapModel({
    required this.track,
    required this.level,
    required this.roadmap,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final result = json["result"] is Map
        ? Map<String, dynamic>.from(json["result"])
        : <String, dynamic>{};

    final data = result["data"] is Map
        ? Map<String, dynamic>.from(result["data"])
        : <String, dynamic>{};

    return RoadmapModel(
      track: data["track"]?.toString() ?? "",
      level: data["level"]?.toString() ?? "",
      roadmap: data["roadmap"] is List
          ? (data["roadmap"] as List)
          .map((e) => RoadmapStepModel.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],
    );
  }
}