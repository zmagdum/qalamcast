import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/models/podcast_data.dart' as PC;
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:podcast_app/firestore_database_maanger/firestore_manager.dart';

import 'dashboard.dart';

class PodcastSeries extends StatefulWidget {
  PodcastSeries({Key key}) : super(key: key);

  @override
  _PodcastSeriesState createState() => _PodcastSeriesState();
}

class _PodcastSeriesState extends State<PodcastSeries> {
  StreamSubscription playerEventSub;
  FireStoreManager manager;

  List<PC.Series> categories = [];

  var isLoading = false;

  @override
  void initState() {
    super.initState();
    topContext = context;

    playerEventSub = miniPlayerUIManager.stream.listen((event) {
      Future.delayed(Duration(milliseconds: 100)).then((e) {
        setState(() {});
      });
    });

    //  init firestore manager
    manager = FireStoreManager();

    // fetch categories
    getSeries();
  }

  @override
  void dispose() {
    super.dispose();
    playerEventSub.cancel();
  }

  getSeries() {
    isLoading = true;

// fetch favourite categories from local storage
    var favcategories = List<PC.Series>();
    SqliteDatabaseManager.shared
        .getFavouriteSeries()
        .then((items) => favcategories = items);

    // fetch categories from firestore
    manager.fetchCategories().then((categories) {
      setState(() {
        this.isLoading = false;
        var favCateIds = favcategories.map((e) => e.title);

        this.categories = categories.map((e) {
          e.isSelected = favCateIds.contains(e.title);
          return e;
        }).toList();
      });
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      builder: (ctx, sizeData) {
        return Column(
          children: [
            AppBar(
              leading: SizedBox(),
              title: Image.asset(Images.APP_LOGO,
                  height: 35, color: Theme.of(context).primaryColor),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(Strings.PODCAST_SERIES,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).secondaryHeaderColor)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Const.HORIZONTAL_PADDING, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.primaryVariant,
                  filled: true,
                  isDense: true,
                  hintText: Strings.SEARCH_FOR_PODCAST,
                  hintStyle: TextStyle(
                      color: MyTheme.isDark
                          ? AppTheme.kWHITE
                          : AppTheme.kBLACK.withOpacity(0.4),
                      fontSize: 12),
                  prefixIcon: Icon(Icons.search,
                      color: MyTheme.isDark
                          ? AppTheme.kWHITE
                          : AppTheme.kBLACK.withOpacity(0.4),
                      size: 25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: AppTheme.kTRANSPARENT),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kTRANSPARENT),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onChanged: (text) {
                  if (text.length > 0) {
                    this.categories = manager.filterCategories(text);
                    setState(() {});
                  } else {
                    setState(() {
                      this.categories = manager.categories;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: this.categories.length,
                      itemBuilder: (ctx, idx) {
                        return PodSeriesBox(categories[idx]);
                      },
                    ),
            )
          ],
        );
      },
    );
  }
}

class PodSeriesBox extends StatefulWidget {
  final PC.Series category;
  PodSeriesBox(this.category, {Key key}) : super(key: key);

  @override
  State<PodSeriesBox> createState() => _PodSeriesBoxState();
}

class _PodSeriesBoxState extends State<PodSeriesBox> {
  PC.Series get category => widget.category;

  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeData) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: EdgeInsets.all(sizeData.screenSize.height * 0.015),
                  child: Image.network(
                    category.artwork,
                    fit: BoxFit.fill,
                    height: 90,
                    width: 90,
                    errorBuilder: (context, obj, tr) {
                      return Image.asset(
                        Images.THUMB_1,
                        fit: BoxFit.fill,
                        height: 90,
                        width: 90,
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(Images.PLAY, height: 34, width: 34),
                )
              ],
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(sizeData.screenSize.height * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(category.title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              Text(category.speaker,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              Text(
                                  "${category.type} •  ${category.episodeCount} Eps",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              category.isSelected = !category.isSelected;

                              SqliteDatabaseManager.shared
                                  .makeFavOrUnFavSeries(category);
                            });
                          },
                          child: SvgPicture.asset(
                            category.isSelected
                                ? Images.FAVORITE
                                : Images.UNFAVORITE,
                            height: 44,
                            width: 44,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Release ${category.releaseDate}",
                            style: TextStyle(
                                fontSize: 12,
                                height: 2,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                        Text("|",
                            style: TextStyle(
                                fontSize: 12,
                                height: 2,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                        Text("Duration ${category.episodeDuration}",
                            style: TextStyle(
                                fontSize: 12,
                                height: 2,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ],
                    ),
                  )
                ],
              ),
            )),
          ],
        ),
      );
    });
  }
}
