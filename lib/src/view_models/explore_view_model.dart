import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/news_response_model.dart';

import 'package:news_app_project/src/models/response_model.dart';


import '../repository/news_repository.dart';

class ExploreViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository = NewsRepository();
  final int _pageSize = 10;

  Response<NewsResponseModel>? newsResponseModel;

  // Future<Response<NewsResponseModel>> getAllNews(
  //   {String country = 'in'}
  // ) async{

  // }
}
