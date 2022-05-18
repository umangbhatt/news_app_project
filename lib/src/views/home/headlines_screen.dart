import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_app_project/src/constants/strings.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/enums/news_category.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/utils/utils.dart';
import 'package:news_app_project/src/view_models/headlines_view_model.dart';
import 'package:news_app_project/src/views/home/weather_widget.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class HeadlinesScreen extends StatelessWidget {
  const HeadlinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: NewsCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kTextTabBarHeight,
          title: TabBar(
              isScrollable: true,
              tabs: NewsCategory.values.map((e) {
                return Tab(
                  text: e.name.capitalizeFirstLetter(),
                );
              }).toList()),
        ),
        body: VxResponsive(
            xlarge: _largeLayout(),
            large: _largeLayout(),
            medium: _mediumLayout(),
            xsmall: _smallLayout(),
            small: _smallLayout()),
      ),
    );
  }

  Widget _smallLayout() {
    return TabBarView(
        children: NewsCategory.values.map((e) {
      return _HeadlinesTab(category: e);
    }).toList());
  }

  Widget _largeLayout() {
    return Container(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1300),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxWidth: 600),
                child: TabBarView(
                    children: NewsCategory.values.map((e) {
                  return _HeadlinesTab(category: e);
                }).toList()),
              ),
            ),
            const SizedBox(width: 16),
            const Padding(
              padding: EdgeInsets.only(right: 32, top: 32),
              child: SizedBox(
                  width: 400,
                  child: WeatherWidget(
                    width: 400,
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _mediumLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(maxWidth: 600),
            child: TabBarView(
                children: NewsCategory.values.map((e) {
              return _HeadlinesTab(category: e);
            }).toList()),
          ),
        ),
        const SizedBox(width: 16),
        const Padding(
          padding: EdgeInsets.only(right: 32, top: 32),
          child: const SizedBox(
              width: 300,
              child: WeatherWidget(
                width: 300,
              )),
        )
      ],
    );
  }
}

class _HeadlinesTab extends StatefulWidget {
  const _HeadlinesTab({Key? key, required this.category}) : super(key: key);
  final NewsCategory category;

  @override
  State<_HeadlinesTab> createState() => _HeadlinesTabState();
}

class _HeadlinesTabState extends State<_HeadlinesTab>
    with AutomaticKeepAliveClientMixin {
  bool isLoadingMoreItems = false;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     // getHeadlines();
    });
  }

  Future getHeadlines() {
    final viewModel = Provider.of<HeadlinesViewModel>(context, listen: false);

    return viewModel.getHeadlines(
      widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getHeadlines();
      },
      child: Selector<HeadlinesViewModel, Response<NewsResponseModel>?>(
          builder: (context, headlinesResponse, child) {
            if (headlinesResponse == null ||
                headlinesResponse.status == Status.loading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (headlinesResponse.status == Status.success) {
              List<Articles> articles = headlinesResponse.data?.articles ?? [];
              if (articles.isEmpty) {
                return Center(
                  child: Text(
                    'No News Items Available',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                );
              } else {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    getMoreItems(scrollInfo, headlinesResponse, context);
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      widget.category == NewsCategory.General
                          ? const SliverToBoxAdapter(
                              child: VxResponsive(
                                small: Padding(
                                  padding: EdgeInsets.only(
                                      left: 24.0,
                                      right: 24,
                                      top: 12,
                                      bottom: 12),
                                  child: SizedBox(
                                    height: 150,
                                    child: WeatherWidget(),
                                  ),
                                ),
                                xsmall: Padding(
                                  padding: EdgeInsets.only(
                                      left: 24.0,
                                      right: 24,
                                      top: 12,
                                      bottom: 12),
                                  child: SizedBox(
                                    height: 150,
                                    child: WeatherWidget(),
                                  ),
                                ),
                                medium: SizedBox(),
                                large: SizedBox(),
                                xlarge: SizedBox(),
                              ),
                            )
                          : const SliverToBoxAdapter(
                              child: SizedBox(),
                            ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return NewsItem(article: articles[index]);
                        }, childCount: articles.length),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 8,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: (articles.length) <
                                (headlinesResponse.data?.totalResults ?? 0)
                            ? const Center(
                                child: CupertinoActivityIndicator(),
                              )
                            : const SizedBox(),
                      ),
                      const SliverPadding(padding: EdgeInsets.only(top: 32)),
                    ],
                  ),
                );
              }
            } else if (headlinesResponse != null &&
                headlinesResponse.status == Status.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        headlinesResponse.message ?? AppStrings.defaultErrorMsg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                            child: const Text('Retry'),
                            onPressed: () {
                              getHeadlines();
                            }),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
          selector: (context, viewModel) =>
              viewModel.headlinesList[widget.category.name]),
    );
  }

  void getMoreItems(ScrollNotification scrollInfo,
      Response<NewsResponseModel> newsResponse, BuildContext context) async {
    final staticViewModel =
        Provider.of<HeadlinesViewModel>(context, listen: false);
    if (!isLoadingMoreItems &&
        scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 56) &&
        (newsResponse.data?.articles.length ?? 0) <
            (newsResponse.data?.totalResults ?? 0)) {
      currentPage = currentPage + 1;
      log('getting data for page $currentPage');
      isLoadingMoreItems = true;
      await staticViewModel.getHeadlinesNextPage(widget.category,
          page: currentPage);
      isLoadingMoreItems = false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: LayoutBuilder(builder: (context, constraints) {
              log('article item width ${constraints.maxWidth}');
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
                      height: 4,
                    ),
                    Text(
                      'Published ${Utils.timeAgoSinceDate(DateTime.parse(article.publishedAt))} ago',
                      style: Theme.of(context).textTheme.caption,
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
