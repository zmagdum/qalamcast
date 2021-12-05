import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podcast_app/downloader.dart';
import 'package:podcast_app/firestore_database_maanger/firestore_manager.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:podcast_app/screens/player_full_screen.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/constants.dart';

class PodcastDetail extends StatefulWidget {
  final Series series;
  PodcastDetail(this.series, {Key key}) : super(key: key);

  @override
  _PodcastDetailState createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  StreamSubscription playerEventSub;

  Series get series => widget.series;
  FireStoreManager manager = FireStoreManager();

  List<Episode> episodes = [];

  @override
  void initState() {
    super.initState();

    playerEventSub = miniPlayerUIManager.stream.listen((event) {
      Future.delayed(Duration(milliseconds: 100)).then((e) {
        setState(() {});
      });
    });

    getEpisodes();
  }

  void getEpisodes() {
    manager.getEpisodesFor(series).then((value) async {
      this.episodes = value;
      var localStoredEpisodes =
          await SqliteDatabaseManager().getAllLocalSavedEpisodes();
      var favEpisodeIds =
          localStoredEpisodes.where((e) => e.isSelected).map((e) => e.id);
      var downloadedEpisodeIds =
          localStoredEpisodes.where((e) => e.downloaded).map((e) => e.id);
      this.episodes.forEach((element) {
        element.isSelected = (favEpisodeIds.contains(element.id));
        element.downloaded = downloadedEpisodeIds.contains(element.id);
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    playerEventSub.cancel();
  }

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            getTopView(context),
            getBodyView(context),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Episode",
                    style: TextStyle(
                      fontSize: 20,
                      color: MyTheme.isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  episodes.length == null
                      ? CircularProgressIndicator()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              top: 0, bottom: isMiniPlayerVisible ? 70 : 20),
                          itemCount: episodes.length,
                          separatorBuilder: (context, i) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            var data = episodes[index];
                            return EpisodeCardWidget(episode: data);
                          },
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container cardWithImage(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      // color: Colors.green,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8, right: 8),
                child: Image.asset(Images.THUMB_1,
                    fit: BoxFit.fill, height: 90, width: 90),
              ),
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(Images.PLAY, height: 34, width: 34),
              )
            ],
          ),
          SizedBox(width: 6),
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Knowledge Intensive",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 20,
                        color: MyTheme.isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Container(
                      // width: screenSize.height * 0.15,
                      child: Text(
                        "Gain the knowledge of how to…",
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Qalam",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          "  •  10 Eps",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Release 28 Apr",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 0.8,
                          color: Colors.grey,
                          height: 13,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Duration 15 Sep",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        isFavorite = !isFavorite;
                        setState(() {});
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                            isFavorite ? Images.FAVORITE : Images.UNFAVORITE,
                            height: 40,
                            width: 30),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                            // data.isDownloaded ? Images.CHECKED :
                            Images.DOWNLOAD,
                            height: 40,
                            width: 30),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // SizedBox(width: 20),
        ],
      ),
    );
  }

  Container getBodyView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 35),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: TextStyle(
                        fontSize: 20,
                        color: MyTheme.isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      series.description,
                      style: TextStyle(
                        fontSize: 18,
                        color: MyTheme.isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "${series.likeCount} likes  -  3 days ago",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(
                  Images.FAVORITE,
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 40,
            width: 215,
            decoration: BoxDecoration(
              color: MyTheme.isDark ? AppTheme.kWHITE : AppTheme.kAPP_BLUE,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerFullScreen(),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    MyTheme.isDark ? Images.PLAY_Dark : Images.PLAY,
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Play Latest Episode",
                  style: TextStyle(
                    fontSize: 16,
                    color: MyTheme.isDark ? AppTheme.kBLACK : AppTheme.kWHITE,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Stack getTopView(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Image.network(
                series.artwork,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.42,
                errorBuilder: (context, obj, tr) {
                  return Image.asset(
                    Images.THUMB_1,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.42,
                  );
                },
              ),

              // Image.asset(
              //   Images.MOSQUE,
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height * 0.42,
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
        ),
        Column(
          children: [
            Image.asset(Images.APP_LOGO, height: 35),
            SizedBox(height: 25),
            Stack(
              children: [
                Row(
                  children: [
                    //back button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 20, top: 8, bottom: 10, right: 5),
                        color: Colors.transparent,
                        child: SvgPicture.asset(Images.BACKARROW),
                      ),
                    ),
                  ],
                ),
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      series.artwork,
                      fit: BoxFit.fill,
                      // width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      errorBuilder: (context, obj, tr) {
                        return Image.asset(
                          Images.THUMB_1,
                          fit: BoxFit.fill,
                          // width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                        );
                      },
                    ),
                    // Image.asset(
                    //   Images.MOSQUE,
                    //   height: MediaQuery.of(context).size.height * 0.3,
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class EpisodeCardWidget extends StatefulWidget {
  const EpisodeCardWidget({
    Key key,
    @required this.episode,
  }) : super(key: key);

  final Episode episode;

  @override
  _EpisodeCardWidgetState createState() => _EpisodeCardWidgetState();
}

class _EpisodeCardWidgetState extends State<EpisodeCardWidget> {
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState()  {
    super.initState();

    Future.delayed(Duration(milliseconds: 200)).then((value) {
      if (DownloadManager.shared.isDownloading(widget.episode)) {
        downloadEpisode();
      }
    });
  }

  downloadEpisode() {
    setState(() {
      isDownloading = true;
    });
    var onProgress = (progress) {
      if (!this.mounted) {
        return;
      }
      setState(() {
        downloadProgress = progress;
      });
    };
    var onDownloadFinish = (file) {
      if (!this.mounted) {
        return;
      }

      setState(() {
        isDownloading = false;
        widget.episode.downloaded = true;
      });
    };
    var onError = (e) {
      if (!this.mounted) {
        return;
      }

      setState(() {
        isDownloading = false;
      });
    };

    if (!DownloadManager.shared.isDownloading(widget.episode)) {
      DownloadManager.shared.donwloadCourse(widget.episode,
          onProgress: onProgress, onDone: onDownloadFinish, onError: onError);
    } else {
      var downloader = DownloadManager.shared.downloaderFor(widget.episode);
      setState(() {
      downloadProgress  = downloader.currentProgress;
      });
      DownloadManager.shared.addListners(
          widget.episode, downloader, onProgress, onError, onDownloadFinish);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today",
                  // data.day.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.episode.title,
                  style: TextStyle(
                    fontSize: 20,
                    color: MyTheme.isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerFullScreen(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: SvgPicture.asset(Images.PLAY,
                                height: 40, width: 40),
                          ),
                        ),
                        SizedBox(width: 15),
                        dateDurationView(widget.episode),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 20),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  // make episode favourite or unfavourite
                  widget.episode.isSelected = !widget.episode.isSelected;

                  SqliteDatabaseManager.shared
                      .makeFavOrUnFavEpisode(widget.episode);
                  setState(() {});
                },
                child: Container(
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                      widget.episode.isSelected
                          ? Images.FAVORITE
                          : Images.UNFAVORITE,
                      // Images.FAVORITE,
                      height: 40,
                      width: 40),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  downloadEpisode();
                },
                child: Container(
                    color: Colors.transparent,
                    //   child:
                    child: Stack(children: [
                      SvgPicture.asset(
                          widget.episode.downloaded
                              ? Images.CHECKED
                              : Images.DOWNLOAD,
                          height: 40,
                          width: 40),
                      if (isDownloading)
                        Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                              value: downloadProgress),
                        )
                    ])),
              ),
            ],
          )
        ],
      ),
    );
  }

  Row dateDurationView(Episode data) {
    return Row(
      children: [
        Text(
          "Release 10 Nov",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 0.8,
          color: Colors.grey,
          height: 13,
        ),
        SizedBox(width: 10),
        Text(
          "${data.duration}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
