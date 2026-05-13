import 'package:graduation/model/admin_user_model.dart';
import 'dio_client.dart';

class AdminApi {

  // ✅ GET USERS
  static Future<List<AdminUserModel>> getUsers() async {
    final response = await DioClient.dio.get("/api/Admin/users");

    final data = response.data;

    return (data as List)
        .map((e) => AdminUserModel.fromJson(e))
        .toList();
  }

  // ✅ MAKE ADMIN
  static Future<void> makeAdmin(int userId) async {
    await DioClient.dio.post("/api/Admin/make-admin/$userId");
  }

  // ✅ DELETE USER
  static Future<void> deleteUser(int userId) async {
    await DioClient.dio.delete("/api/Admin/user/$userId");
  }
}