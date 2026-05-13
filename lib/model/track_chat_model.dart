class TrackChatModel {
  final int id;
  final String content;
  final String sentAt;
  final int senderId;
  final String senderName;
  final int trackId;
  final String senderImageUrl;

  TrackChatModel({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.senderId,
    required this.senderName,
    required this.trackId,
    required this.senderImageUrl,
  });

  factory TrackChatModel.fromJson(Map<String, dynamic> json) {
    return TrackChatModel(
      id: json["id"] ?? 0,
      content: json["content"] ?? "",
      sentAt: json["sentAt"] ?? "",
      senderId: json["senderId"] ?? 0,
      senderName: json["senderName"] ?? "",
      trackId: json["trackId"] ?? 0,
      senderImageUrl: json["senderImageUrl"]?.toString() ?? "",
    );
  }
}