class AppUrls {
  static const String baseUrl = 'http://192.168.8.181:8000'; // 基础接口地址
  static const String baseApiUrl = '$baseUrl/api/client/v1'; // 基础接口地址

  static const String login = '$baseApiUrl/user/signin';
  static const String register = '$baseApiUrl/user/signup';
  static const String getQuickLoginUrl = '$baseApiUrl/passport/auth/getQuickLoginUrl';

  static const String userSubscribe = '$baseApiUrl/user/getSubscribe';
  static const String plan = '$baseApiUrl/plan';
  static const String server = '$baseApiUrl/user/server/fetch';
  static const String userInfo = '$baseApiUrl/user/profile';
}
