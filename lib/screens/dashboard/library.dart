import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:podcast_app/models/sizing_info.dart';
import 'package:podcast_app/screens/dashboard/podcast_detail.dart';
import 'package:podcast_app/screens/reuseable/circle_button.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/utility/constants.dart';
import 'dashboard.dart';

class Library extends StatefulWidget {
  Library({Key key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  StreamSubscription playerEventSub;
  List<Episode> episodes = [];

  @override
  void initState() {
    super.initState();
    topContext = context;

    playerEventSub = miniPlayerUIManager.stream.listen((event) {
      Future.delayed(Duration(milliseconds: 100)).then((e) {
        setState(() {});
      });
    });

    getFavEpisodes();
  }

  @override
  void dispose() {
    super.dispose();
    playerEventSub.cancel();
  }

  getFavEpisodes() async {
    episodes = await SqliteDatabaseManager.shared.getFavouriteEpisodes();
    setState(() {});
  }

  getDownloadedEpisodes() async {
    episodes = await SqliteDatabaseManager.shared.getDownloadedEpisodes();
    setState(() {});
  }

  String selectedTab = Strings.FAVORITES;

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      builder: (context, sizeData) {
        return Column(
          children: [
            AppBar(
              leading: SizedBox(),
              title: Image.asset(Images.APP_LOGO,
                  height: 35, color: Theme.of(context).primaryColor),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(Strings.LIBRARY,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).secondaryHeaderColor)),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: MyTheme.isDark
                      ? AppTheme.kAPP_BLUE.withOpacity(0.2)
                      : AppTheme.kBACK_GREY,
                  borderRadius: BorderRadius.circular(50)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getTabButton(Strings.FAVORITES, sizeData),
                  getTabButton(Strings.DOWNLOADS, sizeData),
                ],
              ),
            ),
            Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.only(
                        right: Const.HORIZONTAL_PADDING,
                        left: Const.HORIZONTAL_PADDING,
                        bottom: 100),
                    itemCount: episodes.length,
                    itemBuilder: (ctx, idx) {
                      return EpisodeCardWidget(episode: episodes[idx]);
                    },
                    separatorBuilder: (ctx, idx) =>
                        Divider(height: sizeData.screenSize.height * 0.05)))
          ],
        );
      },
    );
  }

  Widget getTabButton(String text, SizingInformation sizeData) {
    Color getTabColor({@required String text, bool isTxtColor = false}) {
      if (isTxtColor)
        return text == selectedTab
            ? MyTheme.isDark
                ? AppTheme.kAPP_BLUE
                : AppTheme.kWHITE
            : Theme.of(context).secondaryHeaderColor;
      else
        return text == selectedTab
            ? MyTheme.isDark
                ? AppTheme.kWHITE
                : AppTheme.kAPP_BLUE
            : MyTheme.isDark
                ? AppTheme.kTRANSPARENT
                : AppTheme.kBACK_GREY;
    }

    return MaterialButton(
      onPressed: () => setState(() {
        selectedTab = text;
        if(selectedTab == Strings.FAVORITES) {
          getFavEpisodes(); 
        } else {
          getDownloadedEpisodes();
        }
      }),
      padding: EdgeInsets.zero,
      elevation: 0,
      highlightElevation: 0,
      minWidth: sizeData.screenSize.width * 0.26,
      color: getTabColor(text: text),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: AppTheme.kTRANSPARENT)),
      child: Text(text,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: getTabColor(text: text, isTxtColor: true))),
    );
  }
}

class LibraryBox extends StatelessWidget {
  final Episode episode;
  final bool isFavorites;
  LibraryBox({@required this.episode, @required this.isFavorites, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeData) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today".toUpperCase(),
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppTheme.kTEXT_GREY)),
                      Expanded(
                          child: Text(episode.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5))),
                    ],
                  ),
                ),
                SizedBox(width: sizeData.screenSize.height * 0.06),
                CircleButton(
                    icon: isFavorites ? Icons.favorite : Icons.check_circle,
                    sizeData: sizeData,
                    radius: sizeData.screenSize.height * 0.042)
              ],
            ),
          ),
          SizedBox(height: sizeData.screenSize.height * 0.012),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleButton(icon: Icons.play_arrow, sizeData: sizeData),
              SizedBox(width: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Release ${episode.releaseDate}",
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.secondary)),
                  Text("    |    ",
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.secondary)),
                  Text("Duration ${episode.duration}",
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              )
            ],
          )
        ],
      );
    });
  }
}
