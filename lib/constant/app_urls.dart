class AppUrls {
  static const String baseUrl = 'https://api.excellentconnect.com:443'; // 基础接口地址
  static const String baseApiUrl = '$baseUrl'; // 基础接口地址

  static const String login = '$baseApiUrl/user/signin';
  static const String register = '$baseApiUrl/user/signup';
  static const String getQuickLoginUrl = '$baseApiUrl/user/auth';

  static const String userSubscribe = '$baseApiUrl/sub';
  static const String plan = '$baseApiUrl/plan';
  static const String server = '$baseApiUrl/server';
  static const String userInfo = '$baseApiUrl/user/profile';
}
