import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/view_models/explore_view_model.dart';
import 'package:news_app_project/src/views/home/headlines_screen.dart';
import 'package:news_app_project/src/views/home/news_item.dart';
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

  Map<String, dynamic>? filters;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllNews();
    });
  }

  Future getAllNews() {
    final viewModel = Provider.of<ExploreViewModel>(context, listen: false);

    return viewModel.getAllNews(filters: filters);
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
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () async {
                Map<String, dynamic>? selectedFilters = await showDialog(
                    context: context,
                    builder: (context) {
                      return NewsFiltersDialog(
                        filters: filters,
                      );
                    });

                if (selectedFilters != null) {
                  setState(() {
                    filters = selectedFilters;
                  });
                  getAllNews();
                }
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
                            constraints: const BoxConstraints(maxWidth: 900),
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
      await staticViewModel.getAllNewsNextPage(
          page: currentPage, filters: filters);
      isLoadingMoreItems = false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class NewsFiltersDialog extends StatefulWidget {
  const NewsFiltersDialog({
    Key? key,
    this.filters,
  }) : super(key: key);

  final Map<String, dynamic>? filters;

  @override
  State<NewsFiltersDialog> createState() => _NewsFiltersDialogState();
}

class _NewsFiltersDialogState extends State<NewsFiltersDialog> {
  List<Map<String, String>> sortOptions = [
    {'title': 'Popularity', 'key': 'popularity'},
    {'title': 'Relevance', 'key': 'relevance'},
    {'title': 'Published At', 'key': 'publishedAt'},
  ];

  String selectedOption = 'publishedAt';
  DateTime? from;
  DateTime? to;
  DateFormat displayDateFormat = DateFormat('dd-MM-yyyy');
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.filters != null) {
      selectedOption = widget.filters!['sortBy'] ?? 'publishedAt';
      from = widget.filters!['from'] != null
          ? dateFormat.parse(widget.filters!['from'])
          : null;
      to = widget.filters!['to'] != null
          ? dateFormat.parse(widget.filters!['to'])
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          child: const Text('Clear All'),
          onPressed: () {
            Navigator.of(context).pop(<String, dynamic>{});
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              Map<String, dynamic> filters = {
                'sortBy': selectedOption,
              };

              if (from != null && to != null) {
                filters['from'] = dateFormat.format(from!);
                filters['to'] = dateFormat.format(to!);
              }

              Navigator.of(context).pop(filters);
            },
            child: const Text('Confirm')),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filter by date'),
          const SizedBox(
            height: 8,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From'),
                  const SizedBox(
                    height: 4,
                  ),
                  OutlinedButton.icon(
                      onPressed: () async {
                        DateTime? selected = await showDatePicker(
                            context: context,
                            initialDate: from ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 180)),
                            lastDate: DateTime.now());
                        if (selected != null) {
                          setState(() {
                            from = selected;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(from == null
                          ? 'Select Date'
                          : displayDateFormat.format(from!))),
                ],
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('To'),
                  const SizedBox(
                    height: 4,
                  ),
                  OutlinedButton.icon(
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
                      icon: const Icon(Icons.calendar_today),
                      label: Text(to == null
                          ? 'Select Date'
                          : displayDateFormat.format(to!))),
                ],
              ),
            ],
          ),
          const Divider(),
          const Text('Sort'),
          const SizedBox(
            height: 8,
          ),
          DropdownButton<String>(
              value: selectedOption,
              items: sortOptions
                  .map((e) => DropdownMenuItem<String>(
                      value: e['key'], child: Text(e['title']!)))
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
