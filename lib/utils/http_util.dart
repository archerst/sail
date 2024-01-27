import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sail/constant/app_strings.dart';
import 'package:sail/router/application.dart';
import 'package:sail/router/routers.dart';
import 'package:sail/utils/common_util.dart';
import 'package:sail/utils/shared_preferences_util.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HttpUtil {
  static HttpUtil get instance => _httpUtil;
  static final HttpUtil _httpUtil = HttpUtil();
  late Dio dio;

  HttpUtil() {
    BaseOptions options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    dio = Dio(options);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {

      //如果token存在在请求参数加上token
      await SharedPreferencesUtil.getInstance()?.getString(AppStrings.token).then((token) {
        if (token != null) {
          final headers = <String, String>{
            "Authorization": "Bearer $token"};
          options.headers.addEntries(headers.entries);
          options.queryParameters[AppStrings.token] = token;
          print("token=$token");
        }
      });

      //如果auth_data存在在请求参数加上auth_data
      await SharedPreferencesUtil.getInstance()?.getString(AppStrings.authData).then((authData) {
        if (authData != null) {
          options.queryParameters[AppStrings.authData] = authData;
          print("authData=$authData");
        }
      });

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      await deviceInfo.iosInfo.then((value) {
        final headers = <String, String>{
        "did": value.identifierForVendor??'unknown', 
        "dm": value.model,
        "dt": value.utsname.machine};
        options.headers.addEntries(headers.entries);
      });


      print("========================请求数据===================");
      print("url=${options.uri.toString()}");
      print("headers=${options.headers}");
      print("params=${options.data}");
      return handler.next(options);
    }, onResponse: (response, handler) {
      print("========================返回数据===================");
      print("code=${response.statusCode}");
      print("content=${response.data}");

      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        if (response.statusCode == 403) {
          Application.navigatorKey.currentState?.pushNamed(Routers.login);
        }

        return handler
            .reject(DioError(requestOptions: response.requestOptions, response: response, type: DioErrorType.response));
      }

      return handler.next(response);
    }, onError: (error, handler) {
      print("========================请求错误===================");
      print("message =${error.message}");
      print("code=${error.response?.statusCode}");

      return handler.next(error);
    }));
  }

  //get请求
  Future get(String url, {Map<String, dynamic>? parameters, Options? options}) async {
    Response response;
    if (parameters != null && options != null) {
      response = await dio.get(url, queryParameters: parameters, options: options);
    } else if (parameters != null && options == null) {
      response = await dio.get(url, queryParameters: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.get(url, options: options);
    } else {
      response = await dio.get(url);
    }
    print("get data: ${jsonDecode(response.data)['data']}");
    return jsonDecode(response.data);
  }

  //post请求
  Future post(String url, {Map<String, dynamic>? parameters, Options? options}) async {
    Response response;
    if (parameters != null && options != null) {
      response = await dio.post(url, data: parameters, options: options);
    } else if (parameters != null && options == null) {
      response = await dio.post(url, data: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.post(url, options: options);
    } else {
      response = await dio.post(url);
    }
    return response.data;
  }

  //put请求
  Future put(String url, {Map<String, dynamic>? parameters, Options? options}) async {
    Response response;
    if (parameters != null && options != null) {
      response = await dio.put(url, data: parameters, options: options);
    } else if (parameters != null && options == null) {
      response = await dio.put(url, data: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.put(url, options: options);
    } else {
      response = await dio.put(url);
    }
    return response.data;
  }

  //delete请求
  Future delete(String url, {Map<String, dynamic>? parameters, Options? options}) async {
    Response response;
    if (parameters != null && options != null) {
      response = await dio.delete(url, data: parameters, options: options);
    } else if (parameters != null && options == null) {
      response = await dio.delete(url, data: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.delete(url, options: options);
    } else {
      response = await dio.delete(url);
    }
    return response.data;
  }
}
