import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podcast_app/firestore_database_maanger/firestore_manager.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';
import 'package:podcast_app/screens/dashboard/podcast_detail.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/utility/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription playerEventSub;

  FireStoreManager manager;

  List<Series> favouritesSeries = [];

  @override
  void initState() {
    super.initState();
    topContext = context;
    playerEventSub = miniPlayerUIManager.stream.listen((event) {
      Future.delayed(Duration(milliseconds: 100)).then((e) {
        setState(() {});
      });
    });

    getFavouriteSeries();
  }

  getFavouriteSeries([String searchText]) {
    SqliteDatabaseManager.shared
        .getFavouriteSeries(searchText)
        .then((items) => setState(() {
              this.favouritesSeries = items;
            }));
  }

  @override
  void dispose() {
    super.dispose();
    playerEventSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseWidget(builder: (context, sizeData) {
        return Column(
          children: [
            AppBar(
              leading: SizedBox(),
              title: Image.asset(Images.APP_LOGO,
                  height: 35, color: Theme.of(context).primaryColor),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.HORIZONTAL_PADDING),
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
                    getFavouriteSeries(text);
                  } else {
                    getFavouriteSeries();
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom +
                        (isMiniPlayerVisible ? 120 : 20)),
                // padding: EdgeInsets.symmetric(
                //     vertical: sizeData.screenSize.height * 0.02),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Const.HORIZONTAL_PADDING),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings.EPISODE_OF_WEEK,
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).secondaryHeaderColor,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: sizeData.screenSize.height * 0.015),
                        Card(
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).colorScheme.surface,
                          elevation: 6,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Text(
                                  Strings.EPISODE_HEADING,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  Strings.EPISODE_DESCRIPTION,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: sizeData.screenSize.height * 0.03),
                        Text(
                          Strings.MY_PODCASTS,
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).secondaryHeaderColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sizeData.screenSize.height * 0.01),
                  favouritesSeries.isEmpty
                      ? Center(child: Text("No item found"))
                      : Container(
                          height: (sizeData.screenSize.height * 0.48),
                          child: GridView.extent(
                            scrollDirection: Axis.horizontal,
                            maxCrossAxisExtent: 250,
                            childAspectRatio: 1.25,
                            padding: EdgeInsets.only(left: 20),
                            children: favouritesSeriesWidgets(),
                          ),
                        ),
                  SizedBox(height: sizeData.screenSize.height * 0.0),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  List<Widget> favouritesSeriesWidgets() {
    return favouritesSeries
        .map((series) => podcastItem(context, series))
        .toList();
  }

  GestureDetector podcastItem(BuildContext context, Series item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastDetail(item),
          ),
        );
      },
      child: MyPodcastBox(series: item),
    );
  }
}

class MyPodcastBox extends StatelessWidget {
  final Series series;

  const MyPodcastBox({
    Key key,
    @required this.series,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeData) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: sizeData.screenSize.height * 0.15,
            width: sizeData.screenSize.height * 0.15,
            // padding: EdgeInsets.symmetric(horizontal: Const.HORIZONTAL_PADDING),
            decoration: BoxDecoration(
              // color: AppTheme.kAPP_BLUE,
              border: Border.all(color: AppTheme.kWHITE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                series.artwork,
                fit: BoxFit.fill,
                height: sizeData.screenSize.height * 0.15,
                width: sizeData.screenSize.height * 0.15,
                errorBuilder: (context, obj, tr) {
                  return Image.asset(
                    Images.THUMB_1,
                    fit: BoxFit.fill,
                    height: sizeData.screenSize.height * 0.15,
                    width: sizeData.screenSize.height * 0.15,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: sizeData.screenSize.height * 0.15,
            child: Text(
              series.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).secondaryHeaderColor),
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Text(
                series.type,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                " • ${series.episodeCount} Eps",
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          )
        ],
      );
    });
  }
}
