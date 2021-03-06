import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/news_response_model.dart';

import 'package:news_app_project/src/models/response_model.dart';

import '../repository/news_repository.dart';

class ExploreViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository = NewsRepository();
  final int _pageSize = 10;

  Response<NewsResponseModel>? newsResponseModel;

  Future<Response<NewsResponseModel>> getAllNews(
      {Map<String, dynamic>? filters}) async {
    newsResponseModel = Response.loading();
    notifyListeners();
    Map<String, dynamic> params = {
      'language': 'en',
      'sources': "wired,google-news-in,the-hindu,the-times-of-india,",
      'pageSize': _pageSize,
      'page': 1
    };
    if (filters != null) {
      params.addAll(filters);
    }
    Response<NewsResponseModel> response = await _newsRepository.getAllNews(params);

    newsResponseModel = response;
    notifyListeners();

    return response;
  }

  Future<Response<NewsResponseModel>> getAllNewsNextPage(
      {Map<String, dynamic>? filters, int page = 1}) async {
        Map<String, dynamic> params = {
      'language': 'en',
      'sources': "wired,google-news-in,the-hindu,the-times-of-india,",
      'pageSize': _pageSize,
      'page': page
    };
    if (filters != null) {
      params.addAll(filters);
    }
    Response<NewsResponseModel> response = await _newsRepository.getAllNews(params);

    if (response.status == Status.success && response.data != null) {
      newsResponseModel = Response.completed(NewsResponseModel(
          status: response.data!.status,
          totalResults: response.data!.totalResults,
          articles: (newsResponseModel?.data?.articles ?? []) +
              (response.data?.articles ?? [])));
    } else {
      newsResponseModel = response;
    }

    notifyListeners();
    return response;
  }
}
