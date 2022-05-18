import 'news_source_model.dart';

class Articles {
  Articles({
    required this.source,
     this.author,
    required this.title,
     this.description,
    required this.url,
     this.urlToImage,
    required this.publishedAt,
     this.content,
  });
  late final Source source;
  late final String? author;
  late final String title;
  late final String? description;
  late final String url;
  late final String? urlToImage;
  late final String publishedAt;
  late final String? content;
  
  Articles.fromJson(Map<String, dynamic> json){
    source = Source.fromJson(json['source']);
    author = json['author'] ?? '';
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    url = json['url'] ?? '';
    urlToImage = json['urlToImage'] ??'';
    publishedAt = json['publishedAt'] ?? '';
    content = json['content'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['source'] = source.toJson();
    _data['author'] = author;
    _data['title'] = title;
    _data['description'] = description;
    _data['url'] = url;
    _data['urlToImage'] = urlToImage;
    _data['publishedAt'] = publishedAt;
    _data['content'] = content;
    return _data;
  }
}