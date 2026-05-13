class ProfileTrackModel {
  final int id;
  final String name;
  final String description;

  ProfileTrackModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProfileTrackModel.fromJson(Map<String, dynamic> json) {
    return ProfileTrackModel(
      id: json["id"] ?? json["trackId"] ?? 0,
      name: json["name"]?.toString() ??
          json["trackName"]?.toString() ??
          "",
      description: json["description"]?.toString() ?? "",
    );
  }
}

class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String level;
  final List<ProfileTrackModel> tracks;
  final String? imageUrl;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.level,
    required this.tracks,
    this.imageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json["profile"] is Map<String, dynamic>
        ? json["profile"] as Map<String, dynamic>
        : json;

    final fullName = profile["fullName"]?.toString() ?? "";
    final fullNameParts = fullName.split(" ");

    final List tracksJson = json["tracks"] is List
        ? json["tracks"]
        : profile["tracks"] is List
        ? profile["tracks"]
        : [];

    return ProfileModel(
      firstName: profile["firstName"]?.toString() ??
          profile["first_Name"]?.toString() ??
          (fullNameParts.isNotEmpty ? fullNameParts.first : ""),
      lastName: profile["lastName"]?.toString() ??
          profile["last_Name"]?.toString() ??
          (fullNameParts.length > 1 ? fullNameParts.sublist(1).join(" ") : ""),
      email: profile["email"]?.toString() ?? "",
      phone: profile["phone"]?.toString() ?? "",
      dateOfBirth: profile["dateOfBirth"]?.toString() ??
          profile["birthday"]?.toString() ??
          "",
      level: profile["level"]?.toString() ??
          json["level"]?.toString() ??
          "",
      tracks: tracksJson
          .map((e) => ProfileTrackModel.fromJson(e))
          .toList(),
      imageUrl: profile["imageUrl"]?.toString() ??
          profile["profileImageUrl"]?.toString() ??
          profile["photoUrl"]?.toString(),
    );
  }
}