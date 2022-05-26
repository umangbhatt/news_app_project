import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/repository/news_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository = NewsRepository();
  final int _pageSize = 10;

  Response<NewsResponseModel>? newsResponseModel;

  Future<Response<NewsResponseModel>> searchNews(
     String searchQuery,
      {Map<String, dynamic>? filters}) async {
    newsResponseModel = Response.loading();
    notifyListeners();
    Map<String, dynamic> params = {
      'language': 'en',
      'pageSize': _pageSize,
      'page': 1
    };
    if (filters != null) {
      params.addAll(filters);
    }
    Response<NewsResponseModel> response = await _newsRepository.searchNews(params,searchQuery);

    newsResponseModel = response;
    notifyListeners();

    return response;
  }

  Future<Response<NewsResponseModel>> searchNewsNextPage(
    String searchQuery,
      {Map<String, dynamic>? filters, int page = 1}) async {
        Map<String, dynamic> params = {
      'language': 'en',
      'pageSize': _pageSize,
      'page': page
    };
    if (filters != null) {
      params.addAll(filters);
    }
    Response<NewsResponseModel> response = await _newsRepository.searchNews(params, searchQuery);

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