import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Articles article;
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
            ),
            onPressed: () {
              Share.share(article.url);
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: article.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  
}


