import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/bg/weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';

import 'package:location/location.dart';
import 'package:news_app_project/src/core/locator.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/models/weather_response_model.dart';
import 'package:news_app_project/src/repository/weather_repository.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key, this.width}) : super(key: key);
  final double? width;

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with AutomaticKeepAliveClientMixin {
  LocationData? _locationData;
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;

  Response<WeatherResponseModel>? weatherResponse;
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    Location location = Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {});
    if (_locationData != null) {
      weatherResponse = Response.loading();
      setState(() {});
      weatherResponse = await locator<WeatherRepository>()
          .getWeather(_locationData!.latitude!, _locationData!.longitude!);
      setState(() {});
    }
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_serviceEnabled == null ||
        _permissionGranted == null ||
        _locationData == null) {
      return SizedBox(
          height: 150,
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: const Center(child: CupertinoActivityIndicator()));
    } else if (!_serviceEnabled! ||
        _permissionGranted! != PermissionStatus.granted) {
      return const SizedBox();
    } else {
      if (weatherResponse != null) {
        if (weatherResponse!.status == Status.loading) {
          return SizedBox(
              height: 150,
              width: widget.width ?? MediaQuery.of(context).size.width,
              child: const Center(child: CupertinoActivityIndicator()));
        } else if (weatherResponse!.status == Status.success &&
            weatherResponse!.data != null) {
          WeatherResponseModel weatherResponseModel = weatherResponse!.data!;
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  WeatherBg(
                    weatherType:
                        getWeatherType(weatherResponseModel.weather.first),
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    height: 150,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(weatherResponseModel.weather.first.main),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(weatherResponseModel.name)
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${weatherResponseModel.main.temp.toInt()}°c',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          );
        }
      }
      return const SizedBox();
    }
  }

  WeatherType getWeatherType(Weather desc) {
    DateTime now = DateTime.now();
    bool dayTime = false;

    if (now.hour > 6 && now.hour < 18) {
      dayTime = true;
    }

    if (desc.id >= 200 && desc.id < 300) {
      return WeatherType.thunder;
    } else if (desc.id >= 300 && desc.id < 400) {
      return WeatherType.lightRainy;
    } else if (desc.id >= 500 && desc.id < 600) {
      if (desc.id == 500) {
        return WeatherType.lightRainy;
      } else if (desc.id == 501) {
        return WeatherType.middleRainy;
      } else if (desc.id == 502) {
        return WeatherType.heavyRainy;
      } else if (desc.id == 503) {
        return WeatherType.heavyRainy;
      } else if (desc.id == 504) {
        return WeatherType.heavyRainy;
      } else {
        return WeatherType.lightRainy;
      }
    } else if (desc.id >= 600 && desc.id < 700) {
      if (desc.id == 600 ||
          desc.id == 612 ||
          desc.id == 615 ||
          desc.id == 620) {
        return WeatherType.lightSnow;
      } else if (desc.id == 601 || desc.id == 621 || desc.id == 616) {
        return WeatherType.middleSnow;
      } else if (desc.id == 602 || desc.id == 622) {
        return WeatherType.heavySnow;
      } else {
        return WeatherType.lightSnow;
      }
    } else if (desc.id > 700 && desc.id < 800) {
      if (desc.id == 731 || desc.id == 761) {
        return WeatherType.dusty;
      } else {
        return WeatherType.foggy;
      }
    } else if (desc.id > 800 && desc.id < 900) {
      if (dayTime) {
        return WeatherType.cloudy;
      } else {
        return WeatherType.cloudyNight;
      }
    } else {
      if (dayTime) {
        return WeatherType.sunny;
      } else {
        return WeatherType.sunnyNight;
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
