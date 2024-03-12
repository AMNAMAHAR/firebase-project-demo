import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userPicKey = "USERPICKEY";
  static const String displaynameKey = "USERDISPLAYNAME";

  Future<bool> _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<String?> _get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> saveUserId(String getUserId) async {
    return _save(userIdKey, getUserId);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    return _save(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserName(String getUserName) async {
    return _save(userNameKey, getUserName);
  }

  Future<bool> saveUserPic(String getUserPic) async {
    return _save(userPicKey, getUserPic);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    return _save(displaynameKey, getUserDisplayName);
  }

  Future<String?> getUserId() async {
    return _get(userIdKey);
  }

  Future<String?> getUserName() async {
    return _get(userNameKey);
  }

  Future<String?> getUserEmail() async {
    return _get(userEmailKey);
  }

  Future<String?> getUserPic() async {
    return _get(userPicKey);
  }

  Future<String?> getUserDisplayName() async {
    return _get(displaynameKey);
  }
}
