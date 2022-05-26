import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_app_project/src/constants/strings.dart';
import 'package:news_app_project/src/models/article_model.dart';
import 'package:news_app_project/src/models/news_response_model.dart';
import 'package:news_app_project/src/models/response_model.dart';
import 'package:news_app_project/src/view_models/search_view_model.dart';
import 'package:news_app_project/src/views/home/explore_screen.dart';
import 'package:news_app_project/src/views/home/news_item.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoadingMoreItems = false;
  int currentPage = 1;

  Map<String, dynamic>? filters;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.newsResponseModel = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              alignment: Alignment.center,
              child: SafeArea(
                bottom: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10)),
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back)),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                            child: TextField(
                          onSubmitted: ((value) => searchNews()),
                          textInputAction: TextInputAction.search,
                          controller: searchController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Search'),
                        )),
                        const SizedBox(
                          width: 8,
                        ),
                        IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              searchNews();
                            },
                            icon: const Icon(Icons.search)),
                            SizedBox(width: 8,),
                        IconButton(
                          icon: const Icon(Icons.filter_list_rounded),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            Map<String, dynamic>? selectedFilters =
                                await showDialog(
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
                              searchNews();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Selector<SearchViewModel, Response<NewsResponseModel>?>(
                  builder: (context, allNewsResponse, child) {
                    if (allNewsResponse == null) {
                      return SizedBox();
                    } else if (allNewsResponse.status == Status.loading) {
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
                                            (allNewsResponse
                                                    .data?.totalResults ??
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
                                      searchNews();
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
                      viewModel.newsResponseModel),
            ))
          ],
        ),
      ),
    );
  }

  void searchNews() {
    if (searchController.text.trim().isNotEmpty) {
      final viewModel = Provider.of<SearchViewModel>(context, listen: false);

      viewModel.searchNews(searchController.text.trim(), filters: filters);
    }
  }

  void getMoreItems(ScrollNotification scrollInfo,
      Response<NewsResponseModel> newsResponse, BuildContext context) async {
    final staticViewModel =
        Provider.of<SearchViewModel>(context, listen: false);
    if (!isLoadingMoreItems &&
        scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 56) &&
        (newsResponse.data?.articles.length ?? 0) <
            (newsResponse.data?.totalResults ?? 0)) {
      currentPage = currentPage + 1;
      log('getting data for page $currentPage');
      isLoadingMoreItems = true;
      await staticViewModel.searchNewsNextPage(searchController.text.trim(),
          page: currentPage, filters: filters);
      isLoadingMoreItems = false;
    }
  }
}
