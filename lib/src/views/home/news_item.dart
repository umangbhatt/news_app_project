import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:news_app_project/src/constants/strings.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/view_models/news_summary_view_model.dart';
import 'package:news_app_project/src/views/home/article_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/utils.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Articles article;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (kIsWeb) {
              launchUrlString(article.url);
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ArticleScreen(article: article);
              }));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return SizedBox(
                  height: 230,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                article.description ?? '',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                article.source.name,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const Spacer(),
                              Text(
                                'Published ${Utils.timeAgoSinceDate(DateTime.parse(article.publishedAt))} ago',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          )),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 3,
                          child: Container(
                            height: double.maxFinite,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: article.urlToImage ?? '',
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context).cardColor,
                                child: Center(
                                    child: Icon(
                                  Icons.newspaper,
                                  size: 48,
                                  color: Colors.grey.shade700,
                                )),
                              ),
                            ),
                          ))
                    ],
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: article.urlToImage ?? '',
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                  child: Icon(
                                Icons.newspaper,
                                size: 48,
                                color: Colors.grey.shade700,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          article.source.name,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Selector<NewsSummaryViewModel, Articles?>(
                            selector: (context, model) =>
                                model.currentlyPlaying,
                            builder: (context, currentlyPlaying, _) {
                              bool playing = currentlyPlaying != null &&
                                  currentlyPlaying.url == article.url;

                              return OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24))),
                                  onPressed: () {
                                    NewsSummaryViewModel summaryViewModel =
                                        Provider.of<NewsSummaryViewModel>(
                                            context,
                                            listen: false);
                                    if (playing) {
                                      Response<String> response =
                                          summaryViewModel.stopPlaying();
                                      if (response.status == Status.error) {
                                        Utils.showErrorSnackBar(
                                            context,
                                            response.message ??
                                                AppStrings.defaultErrorMsg,
                                            true);
                                      }
                                    } else {
                                      Response<String> response =
                                          summaryViewModel
                                              .playNewsSummary(article);
                                      if (response.status == Status.error) {
                                        Utils.showErrorSnackBar(
                                            context,
                                            response.message ??
                                                AppStrings.defaultErrorMsg,
                                            true);
                                      }
                                    }
                                  },
                                  icon: playing
                                      ? Icon(
                                          Icons.pause_circle_rounded,
                                          size: 16,
                                        )
                                      : Icon(
                                          Icons.play_circle_fill_rounded,
                                          size: 16,
                                        ),
                                  label: Text(
                                    'Summary',
                                    style: TextStyle(fontSize: 14),
                                  ));
                            }),
                        const Spacer(),
                        Text(
                          'Published ${Utils.timeAgoSinceDate(DateTime.parse(article.publishedAt))} ago',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ],
                );
              }
            }),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
        )
      ],
    );
  }
}
