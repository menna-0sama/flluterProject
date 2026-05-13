class ChatMessageModel {
  final int id;
  final String content;
  final String senderName;
  final int trackId;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderName,
    required this.trackId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json["id"] ?? 0,
      content: json["content"] ?? "",
      senderName: json["senderName"] ?? "",
      trackId: json["trackId"] ?? 0,
    );
  }
}