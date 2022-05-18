import 'dart:developer';

import 'package:news_app_project/src/api/api_constants.dart';
import 'package:news_app_project/src/api/weather_api_client.dart';
import 'package:news_app_project/src/core/locator.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/models/weather_response_model.dart';

class WeatherRepository {
  Future<Response<WeatherResponseModel>> getWeather(
      double lat, double long) async {
    Response response = await locator<WeatherApiClient>()
        .getRequest(url: ApiConstants.weatherURL, params: {
      'lat': lat,
      'lon': long,
      'units': 'metric',
    });
    if (response.status == Status.success && response.data != null) {
      return Response.completed(WeatherResponseModel.fromJson(response.data));
    } else {
      return Response.error(response.message);
    }
  }
}
