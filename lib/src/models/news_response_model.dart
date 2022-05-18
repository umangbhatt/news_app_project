

import 'article_model.dart';

class NewsResponseModel {
  NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });
  late final String status;
  late final int totalResults;
  late final List<Articles> articles;
  
  NewsResponseModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    totalResults = json['totalResults'];
    articles = List.from(json['articles']).map((e)=>Articles.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['totalResults'] = totalResults;
    _data['articles'] = articles.map((e)=>e.toJson()).toList();
    return _data;
  }
}




