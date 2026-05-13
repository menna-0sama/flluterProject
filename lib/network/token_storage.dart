class TokenStorage {
  static String token = "";

  static void saveToken(String newToken) {
    token = newToken;
  }

  static String getToken() {
    return token;
  }

  static bool hasToken() {
    return token.isNotEmpty;
  }

  static void clearToken() {
    token = "";
  }
}