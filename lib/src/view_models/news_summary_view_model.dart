import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/response_model.dart';

class NewsSummaryViewModel extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  NewsSummaryViewModel() {
    // {name: en-in-x-ahp-local, locale: en-IN}, {name: en-in-x-end-local, locale: en-IN}
    _flutterTts.setLanguage('en-IN');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1);
   // _flutterTts.setVoice({'name': 'en-in-x-ahp-local', 'locale': 'en-IN'});
    _flutterTts.setVoice({'name': 'en-in-x-end-local', 'locale': 'en-IN'});

    _flutterTts.setCompletionHandler(_onComplete);
  }

  Articles? currentlyPlaying;

  Response<String> playNewsSummary(Articles article) {
    try {
      if (currentlyPlaying != null) {
        _flutterTts.stop();
      }
      if (article.description != null || article.description!.isNotEmpty) {
        currentlyPlaying = article;
        _flutterTts.speak(article.description!);
      }
      notifyListeners();
      return Response.completed('');
    } catch (e) {
      log('error playing summary $e');
      currentlyPlaying = null;
      notifyListeners();
      return Response.error(e.toString());
    }
  }

  Response<String> stopPlaying() {
    try {
      _flutterTts.stop();
      currentlyPlaying = null;
      notifyListeners();
      return Response.completed('');
    } catch (e) {
      log('error stopping summary $e');
      currentlyPlaying = null;
      notifyListeners();
      return Response.error(e.toString());
    }
  }

  bool get isPlaying => currentlyPlaying != null;

  void _onComplete() {
    currentlyPlaying = null;
    notifyListeners();
  }
}
