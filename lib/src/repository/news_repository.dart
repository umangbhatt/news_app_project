import 'dart:developer';

import 'package:news_app_project/src/api/news_api_client.dart';
import 'package:news_app_project/src/api/api_constants.dart';
import 'package:news_app_project/src/core/locator.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';

import '../constants/strings.dart';

class NewsRepository {
  Future<Response<NewsResponseModel>> getNewsHeadlines(
      Map<String, dynamic> params) async {
    Response<dynamic> response = await locator<NewsApiClient>()
        .getRequest(url: ApiConstants.topHeadlinesURL, params: params);

    if (response.status == Status.error) {
      return Response.error(response.message);
    } else {
      try {
        return Response.completed(
          NewsResponseModel.fromJson(response.data),
        );
      } catch (e) {
        log('error in parsing news headlines data $e');
        return Response.error(AppStrings.defaultErrorMsg);
      }
    }
  }

  Future<Response<NewsResponseModel>> getAllNews(
      Map<String, dynamic> params) async {
    Response<dynamic> response = await locator<NewsApiClient>()
        .getRequest(url: ApiConstants.everythingURL, params: params);

    if (response.status == Status.error) {
      return Response.error(response.message);
    } else {
      try {
        return Response.completed(
          NewsResponseModel.fromJson(response.data),
        );
      } catch (e) {
        log('error in parsing all news data $e');
        return Response.error(AppStrings.defaultErrorMsg);
      }
    }
  }


}
