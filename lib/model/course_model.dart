class CourseModel {
  final int id;
  final String title;
  final String description;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json["id"] ?? json["courseId"] ?? 0,
      title: json["title"] ?? json["name"] ?? "Course",
      description: json["description"] ?? "No description available",
    );
  }
}