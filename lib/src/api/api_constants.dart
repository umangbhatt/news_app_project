class ApiConstants {
  static const String newsBaseUrl = 'https://newsapi.org/v2';

  static const String newApiKey = '2375f3c78a9449949d1b2ded481f3aae';
  //4f246f76ee2a4ab085d9762f83507ad5

  static const String weatherURL = 'https://api.openweathermap.org/data/2.5/weather';
  static const String weatherApiKey = '6e330cafbe96634f3825ce56c4bd99e1';

  static const String _everythingPoint = '/everything';
  static const String everythingURL = newsBaseUrl + _everythingPoint;

  static const String _topHeadlinesPoint = '/top-headlines';
  static const String topHeadlinesURL = newsBaseUrl + _topHeadlinesPoint;

  static const String _sourcesPoint = '/top-headlines/sources';
  static const String sourcesURL = newsBaseUrl + _sourcesPoint;
}
