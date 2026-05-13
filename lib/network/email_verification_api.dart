import 'dio_client.dart';

class EmailVerificationApi {
  Future verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await DioClient.dio.post(
      "/api/Auth/verify-email",
      data: {
        "email": email,
        "code": code,
      },
    );

    return response.data;
  }
}