
import '../config/global.dart';

/// 账户相关数据存取
class AccountUtils {
  static const String spPrivacyAgree = "sp_privacy_agree";
  static const String spUserId = "sp_user_id";
  static const String spUserAvatar = "sp_user_avatar";
  static const String spUserNickName = "sp_user_nick_name";

  ///webdav链接
  static const String spKeyOfWebdavUrl = "sp_key_of_webdav_url";

  ///webdav用户名
  static const String spKeyOfWebdavUsername = "sp_key_of_webdav_username";

  ///webdav密码
  static const String spKeyOfWebdavPwd = "sp_key_of_webdav_pwd";

  static const String spKeyOfCustomFontName = "sp_key_of_custom_font_name";

  /// 是否同意隐私协议
  static bool isAgreePrivacy() {
    return Global.prefs!.getBool(spPrivacyAgree) ?? false;
  }

  /// 保存是否同意隐私协议
  static Future<bool> setAgreePrivacy(bool agree) {
    return Global.prefs!.setBool(spPrivacyAgree, agree);
  }

  /// 获取是否登录
  static bool isLogin() {
    String? token = getUserId();
    return token == null ? false : token.isNotEmpty;
  }

  /// 获取登录用户Id
  static String? getUserId() {
    return Global.prefs!.getString(spUserId);
  }

  /// 保存登录用户Id
  static Future<bool> setUserId(String value) {

    return Global.prefs!.setString(spUserId, value);
  }


  /// 获取头像
  static String? getAvatar() {
    return Global.prefs!.getString(spUserAvatar);
  }

  /// 保存头像
  static Future<bool> setAvatar(String? value) {
    return setString(spUserAvatar, value);
  }

  /// 保存用户名
  static Future<bool> setNickname(String? value) {
    return setString(spUserNickName, value);
  }

  /// 获取用户名
  static String? getNickname() {
    return Global.prefs!.getString(spUserNickName);
  }

  /// 获取字符串
  static String? getString(String key, {String? defValue}) {
    return Global.prefs!.getString(key) ?? defValue;
  }

  /// 保存字符串
  static Future<bool> setString(String key, String? value) {
    if (value == null) {
      return Global.prefs!.remove(key);
    }
    return Global.prefs!.setString(key, value);
  }

}
