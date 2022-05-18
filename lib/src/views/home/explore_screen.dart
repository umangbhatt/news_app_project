import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/view_models/explore_view_model.dart';
import 'package:news_app_project/src/views/home/headlines_screen.dart';
import 'package:provider/provider.dart';

import '../../constants/strings.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  bool isLoadingMoreItems = false;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // getAllNews();
    });
  }

  Future getAllNews() {
    final viewModel = Provider.of<ExploreViewModel>(context, listen: false);

    return viewModel.getAllNews();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getAllNews();
      },
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.filter_list_rounded),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return NewsFiltersDialog();
                    });
              },
            ),
          ),
          Expanded(
            child: Selector<ExploreViewModel, Response<NewsResponseModel>?>(
                builder: (context, allNewsResponse, child) {
                  if (allNewsResponse == null ||
                      allNewsResponse.status == Status.loading) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else if (allNewsResponse.status == Status.success) {
                    List<Articles> articles =
                        allNewsResponse.data?.articles ?? [];
                    if (articles.isEmpty) {
                      return Center(
                        child: Text(
                          'No Headlines Available',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      );
                    } else {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          getMoreItems(scrollInfo, allNewsResponse, context);
                          return false;
                        },
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 900),
                            child: CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      (context, index) {
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
                                          (allNewsResponse.data?.totalResults ??
                                              0)
                                      ? const Center(
                                          child: CupertinoActivityIndicator(),
                                        )
                                      : const SizedBox(),
                                ),
                                const SliverPadding(
                                    padding: EdgeInsets.only(top: 32)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (allNewsResponse.status == Status.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              allNewsResponse.message ??
                                  AppStrings.defaultErrorMsg,
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
                                    getAllNews();
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
                selector: (context, viewModel) => viewModel.newsResponseModel),
          ),
        ],
      ),
    );
  }

  void getMoreItems(ScrollNotification scrollInfo,
      Response<NewsResponseModel> newsResponse, BuildContext context) async {
    final staticViewModel =
        Provider.of<ExploreViewModel>(context, listen: false);
    if (!isLoadingMoreItems &&
        scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 56) &&
        (newsResponse.data?.articles.length ?? 0) <
            (newsResponse.data?.totalResults ?? 0)) {
      currentPage = currentPage + 1;
      log('getting data for page $currentPage');
      isLoadingMoreItems = true;
      await staticViewModel.getAllNewsNextPage(page: currentPage);
      isLoadingMoreItems = false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class NewsFiltersDialog extends StatefulWidget {
  const NewsFiltersDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<NewsFiltersDialog> createState() => _NewsFiltersDialogState();
}

class _NewsFiltersDialogState extends State<NewsFiltersDialog> {
  List<String> sortOptions = [
    'Default',
    'Popularity',
    'Relevance',
    'Published At',
  ];

  String selectedOption = 'default';
  DateTime? from;
  DateTime? to;
  DateFormat displayDateFormat = DateFormat('dd-MM-yyyy');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        
        }, child: Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.pop(context);
        
        }, child: Text('Confirm')),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter'),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () async {
                        DateTime? selected = await showDatePicker(
                            context: context,
                            initialDate: from?? DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 180)),
                            lastDate: DateTime.now());
                        if (selected != null) {
                          setState(() {
                            from = selected;
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                      label: Text(from == null
                          ? 'From'
                          : displayDateFormat.format(from!)))),
              SizedBox(
                width: 8,
              ),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: from != null
                          ? () async {
                              DateTime? selected = await showDatePicker(
                                  context: context,
                                  initialDate: to ?? from!,
                                  firstDate: from!,
                                  lastDate: DateTime.now());
                              if (selected != null) {
                                setState(() {
                                  to = selected;
                                });
                              }
                            }
                          : null,
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                          to == null ? 'To' : displayDateFormat.format(to!)))),
            ],
          ),
          Divider(),
          Text('Sort'),
          SizedBox(
            height: 8,
          ),
          DropdownButton<String>(
              value: selectedOption,
              items: sortOptions
                  .map((e) => DropdownMenuItem<String>(
                      value: e.toLowerCase().replaceAll(' ', ''),
                      child: Text(e)))
                  .toList(),
              onChanged: (value) {
                selectedOption = value ?? 'default';
                setState(() {});
              })
        ],
      ),
    );
  }
}
