import 'dart:io';
import 'package:dio/dio.dart';
import 'package:graduation/model/profile_model.dart';
import 'package:graduation/network/dio_client.dart';

class ProfileApi {
  static Future<ProfileModel> getProfile() async {
    try {
      final response = await DioClient.dio.get("/api/Profile");

      print("GET PROFILE STATUS: ${response.statusCode}");
      print("GET PROFILE RESPONSE: ${response.data}");

      final data = response.data;

      if (data is Map && data["data"] is Map<String, dynamic>) {
        return ProfileModel.fromJson(data["data"]);
      }

      if (data is Map<String, dynamic>) {
        return ProfileModel.fromJson(data);
      }

      throw Exception("Invalid profile response");
    } on DioException catch (e) {
      print("GET PROFILE ERROR STATUS: ${e.response?.statusCode}");
      print("GET PROFILE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load profile");
    }
  }

  static Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "dateOfBirth": dateOfBirth,
      };

      print("UPDATE PROFILE BODY: $body");

      final response = await DioClient.dio.put(
        "/api/Profile",
        data: body,
      );

      print("UPDATE PROFILE STATUS: ${response.statusCode}");
      print("UPDATE PROFILE RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("UPDATE PROFILE ERROR STATUS: ${e.response?.statusCode}");
      print("UPDATE PROFILE ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to update profile");
    }
  }

  static Future<dynamic> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      print("UPLOAD IMAGE PATH: ${imageFile.path}");
      print("UPLOAD IMAGE NAME: $fileName");
      print("UPLOAD IMAGE SIZE: ${await imageFile.length()} bytes");

      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType("image", "jpeg"),
      );

      final formData = FormData.fromMap({
        "file": multipartFile,
      });

      final response = await DioClient.dio.post(
        "/api/Profile/upload-image",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
        ),
      );

      print("UPLOAD IMAGE STATUS: ${response.statusCode}");
      print("UPLOAD IMAGE RESPONSE: ${response.data}");

      return response.data;
    } on DioException catch (e) {
      print("UPLOAD IMAGE ERROR STATUS: ${e.response?.statusCode}");
      print("UPLOAD IMAGE ERROR BODY: ${e.response?.data}");
      print("UPLOAD IMAGE ERROR MESSAGE: ${e.message}");
      throw Exception("Failed to upload image");
    } catch (e) {
      print("UPLOAD IMAGE GENERAL ERROR: $e");
      throw Exception("Failed to upload image");
    }
  }
}