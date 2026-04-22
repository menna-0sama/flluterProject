import 'dio_client.dart';

class AuthApi {

  // 🆕 REGISTER
  Future registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Auth/register",
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "dateOfBirth": dateOfBirth,
      },
    );

    return response.data;
  }

  // 🔐 LOGIN
  Future loginUser({
    required String email,
    required String password,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    // 🔥 حفظ التوكن
    DioClient.accessToken = response.data["accessToken"];
    DioClient.refreshToken = response.data["refreshToken"];

    return response.data;
  }

  // 🔵 GOOGLE LOGIN (إضافة جديدة فقط)
  Future googleLogin({
    required String idToken,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Auth/google-login",
      data: {
        "idToken": idToken,
      },
    );

    // 🔥 حفظ التوكن بعد Google login
    DioClient.accessToken = response.data["accessToken"];
    DioClient.refreshToken = response.data["refreshToken"];

    return response.data;
  }
}