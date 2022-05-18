
import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/enums/news_category.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/repository/news_repository.dart';

import '../utils/enums/view_model_status.dart';

class HeadlinesViewModel extends ChangeNotifier {
  ViewStatus viewStatus = ViewStatus.complete;

  void setViewStatus(ViewStatus status) {
    viewStatus = status;
    notifyListeners();
  }

  final NewsRepository _newsRepository = NewsRepository();

  final int _pageSize = 10;
  late Map<String, Response<NewsResponseModel>?> headlinesList;

  HeadlinesViewModel() {
    headlinesList = {};
    for (var category in NewsCategory.values) {
      headlinesList[category.name] = null;
    }
  }

  Future<Response<NewsResponseModel>> getHeadlines(NewsCategory category,
      {String country = 'in'}) async {
    headlinesList[category.name] = Response.loading();
    notifyListeners();
    Response<NewsResponseModel> response = await _newsRepository
        .getNewsHeadlines({
      'country': country,
      'category': category.name,
      'pageSize': _pageSize,
      'page': 1
    });

    headlinesList[category.name] = response;
    notifyListeners();

    return response;
  }

  Future<Response<NewsResponseModel>> getHeadlinesNextPage(
      NewsCategory category,
      {String country = 'in',
      int page = 1}) async {
    Response<NewsResponseModel> response =
        await _newsRepository.getNewsHeadlines({
      'country': country,
      'category': category.name,
      'pageSize': _pageSize,
      'page': page
    });

    if (response.status == Status.success && response.data != null) {
      Response<NewsResponseModel>? oldResponse = headlinesList[category.name];

      headlinesList[category.name] = Response.completed(NewsResponseModel(
          status: response.data!.status,
          totalResults: response.data!.totalResults,
          articles: (oldResponse?.data?.articles ?? []) +
              (response.data?.articles ?? [])));
    } else {
      headlinesList[category.name] = response;
    }

    notifyListeners();
    return response;
  }
}
