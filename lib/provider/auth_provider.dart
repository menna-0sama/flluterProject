import 'package:flutter/material.dart';
import 'package:graduation/network/sing-inAPI.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  bool isLoading = false;

  // 🔐 LOGIN
  Future login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authApi.loginUser(
        email: email,
        password: password,
      );

      isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  // 🆕 REGISTER
  Future register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authApi.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

      isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  // 🔵 GOOGLE LOGIN
  Future googleLogin({
    required String idToken,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authApi.googleLogin(
        idToken: idToken,
      );

      isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      rethrow;
    }
  }
}