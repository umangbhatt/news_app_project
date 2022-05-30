import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Articles article;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  double? progress;
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
              Share.share(widget.article.url);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          WebView(
            onPageStarted: (url) {
              progress = 0;
              setState(() {});
            },
            onPageFinished: (url) {
              progress = null;
              setState(() {});
            },
            onProgress: (value) {
              setState(() {
                progress = value / 100;
              });
            },
            initialUrl: widget.article.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
          progress != null
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                  ))
              : const SizedBox()
        ],
      ),
    );
  }
}
