class CourseProgressItem {
  final int id;
  final String title;
  final String description;
  final int progress;

  CourseProgressItem({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
  });

  factory CourseProgressItem.fromJson(Map<String, dynamic> json) {
    return CourseProgressItem(
      id: json["id"] ?? 0,
      title: json["title"] ?? json["name"] ?? "",
      description: json["description"] ?? "",
      progress: json["progress"] ?? 0,
    );
  }
}