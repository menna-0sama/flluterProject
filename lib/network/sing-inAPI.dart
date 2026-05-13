import 'dio_client.dart';

class AuthApi {
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

    final data = response.data;

    print("LOGIN RESPONSE: $data");

    final token = data["token"] ?? data["data"]?["token"];
    final refreshToken = data["refreshToken"] ?? data["data"]?["refreshToken"];

    if (token == null || refreshToken == null) {
      throw Exception("Login failed: token not found in response");
    }

    await DioClient.saveTokens(
      token: token,
      refresh: refreshToken,
    );

    print("✅ TOKEN SAVED PERMANENTLY");

    return data;
  }

  Future googleLogin({
    required String idToken,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Auth/google-login",
      data: {
        "idToken": idToken,
      },
    );

    final data = response.data;

    print("GOOGLE LOGIN RESPONSE: $data");

    final token = data["token"] ?? data["data"]?["token"];
    final refreshToken = data["refreshToken"] ?? data["data"]?["refreshToken"];

    if (token == null || refreshToken == null) {
      throw Exception("Google login failed: token not found in response");
    }

    await DioClient.saveTokens(
      token: token,
      refresh: refreshToken,
    );

    print("✅ GOOGLE TOKEN SAVED PERMANENTLY");

    return data;
  }
}