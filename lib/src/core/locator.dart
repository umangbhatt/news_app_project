import 'package:get_it/get_it.dart';
import 'package:news_app_project/src/api/news_api_client.dart';
import 'package:news_app_project/src/api/weather_api_client.dart';
import 'package:news_app_project/src/repository/news_repository.dart';
import 'package:news_app_project/src/repository/weather_repository.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<NewsApiClient>(() => NewsApiClient());
  locator.registerLazySingleton<NewsRepository>(() => NewsRepository());
  locator.registerLazySingleton<WeatherApiClient>(() => WeatherApiClient());
  locator.registerLazySingleton<WeatherRepository>(() => WeatherRepository());
}
