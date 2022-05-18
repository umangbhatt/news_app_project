import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_project/src/api/api_constants.dart';
import 'package:news_app_project/src/constants/strings.dart';
import 'package:news_app_project/src/models/response_model.dart' as res;

class WeatherApiClient {
  final Dio _apiClient = Dio();

  final Options _options = Options(
    sendTimeout: 30 * 1000,
    receiveTimeout: 30 * 1000,
  );

  Future<res.Response<dynamic>> getRequest({
    required String url,
    Map<String,dynamic> params = const {},
  }) async {
    try {
      params['appid'] = ApiConstants.weatherApiKey;
      log('##Request##\n$url\n$params');

      Response response =
          await _apiClient.get(url, queryParameters: params, options: _options);
      log('##Response##\n${response.statusCode ?? ''}\n${response.statusMessage ?? ''}\n$response');

      if (response.statusCode == 200) {
        return res.Response.completed(response.data);
      } else {
        return res.Response.error(
            response.data['message'] ?? AppStrings.defaultErrorMsg);
      }
    } on DioError catch (e) {
      log(e.message);
      switch (e.type) {
        case DioErrorType.response:
          log('${e.response}');
          if (e.response?.data != null &&
              e.response?.data is Map<String, dynamic> &&
              e.response?.data.containsKey('message') &&
              e.response?.data['message'] is String) {
            return res.Response.error(
                e.response?.data['message'] ?? AppStrings.defaultErrorMsg);
          } else {
            return res.Response.error(AppStrings.defaultErrorMsg);
          }
        case DioErrorType.connectTimeout:
          {
            return res.Response.error(AppStrings.timeoutErrorMsg);
          }
        case DioErrorType.sendTimeout:
          {
            return res.Response.error(AppStrings.timeoutErrorMsg);
          }
        case DioErrorType.receiveTimeout:
          {
            return res.Response.error(AppStrings.timeoutErrorMsg);
          }
        case DioErrorType.other:
          if (e.error is SocketException) {
            return res.Response.error(AppStrings.noInternetErrorMsg);
          } else {
            return res.Response.error(AppStrings.defaultErrorMsg);
          }
        default:
          return res.Response.error(AppStrings.defaultErrorMsg);
      }
    } catch (e) {
      log(e.toString());
      return res.Response.error(AppStrings.defaultErrorMsg);
    }
  }
}
