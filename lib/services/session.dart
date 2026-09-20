import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const String userIdKey = 'user_id';
  static const String businessIdKey = 'business_id';

  static Future<void> saveUser({
    required int userId,
    int? businessId,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      userIdKey,
      userId,
    );

    if (businessId != null) {
      await prefs.setInt(
        businessIdKey,
        businessId,
      );
    }
  }

  static Future<int?> getUserId() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(userIdKey);
  }

  static Future<int?> getBusinessId() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(businessIdKey);
  }

  static Future<void> saveBusinessId(
    int businessId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      businessIdKey,
      businessId,
    );
  }

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}