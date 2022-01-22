import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:podcast_app/AudioPlayer/audio_player_manager.dart';
import 'package:podcast_app/downloader.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:podcast_app/screens/reuseable/episode_buttons.dart';

import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';

class PlayerFullScreen extends StatefulWidget {
  final List<Episode>? episodes;
  var index = 0;
  PlayerFullScreen({Key? key, this.episodes, this.index = 0}) : super(key: key);

  @override
  _PlayerFullScreenState createState() => _PlayerFullScreenState();
}

class _PlayerFullScreenState extends State<PlayerFullScreen> {
  var sliderValue = 0.0;
  var totalTime = "0:00";
  var currentTime = "0:00";
  var isSliderDragging = false;

  @override
  void initState() {
    super.initState();

    MediaPlayer.shared.addListners(
        onProgress: (progress, currentTime, totalTime) {
          if (!this.mounted) {
            return;
          }
          if (!isSliderDragging) {
            this.currentTime = currentTime;
            this.totalTime = totalTime;
            sliderValue = progress;

            setState(() {});
          }
        },
        onComplete: () {},
        onError: (error) {});

    MediaPlayer.shared.currenItemIndex = widget.index;
    MediaPlayer.shared.episodes = widget.episodes;
    MediaPlayer.shared.currentPlayingEpisode = widget.episodes![widget.index];
    MediaPlayer.shared.play(episode: widget.episodes![widget.index]);

    // hide mini player if opened
    miniPlayerUIManager.add(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            Images.BLURBG,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 30, bottom: isMiniPlayerVisible ? 70 : 10),
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        miniPlayerUIManager.add(1);
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset(Images.DOWNARROW,
                            color:
                                MyTheme.isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              Images.MOSQUE1,
                              width: MediaQuery.of(context).size.width - 40,
                              height: MediaQuery.of(context).size.width - 50,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Hadith Intensive",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              "A week-long experience with the sciences of the Hadith taught by Mufti Hussain Kamani",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "Release 28 Apr",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: MyTheme.isDark
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  width: 0.8,
                                  color: MyTheme.isDark
                                      ? Colors.white
                                      : Colors.grey,
                                  height: 10,
                                ),
                                Text(
                                  "Duration 15 Sep",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: MyTheme.isDark
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Center(
                                  child: Icon(Icons.replay_10,
                                      size: 30,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : HexColor("#114A70")),
                                ),
                                onPressed: () {
                                  MediaPlayer.shared
                                      .toggleSeek(isBackSeek: true);
                                }),
                            IconButton(
                                icon: Icon(Icons.skip_previous,
                                    size: 44,
                                    color: MyTheme.isDark
                                        ? Colors.white
                                        : HexColor("#114A70")),
                                onPressed: () {
                                  MediaPlayer.shared.playPreviouse();
                                  setState(() {});
                                }),
                            IconButton(
                                icon: Icon(
                                    MediaPlayer.shared.isPlaying
                                        ? Icons.pause
                                        : Icons.play_circle_fill,
                                    size: 44,
                                    color: MyTheme.isDark
                                        ? Colors.white
                                        : HexColor("#114A70")),
                                onPressed: () {
                                  MediaPlayer.shared.togglePlaying();
                                  setState(() {});
                                }),
                            IconButton(
                                icon: Center(
                                  child: Icon(Icons.skip_next,
                                      size: 44,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : HexColor("#114A70")),
                                ),
                                onPressed: () {
                                  MediaPlayer.shared.playNext();
                                  setState(() {});
                                }),
                            IconButton(
                                icon: Center(
                                  child: Icon(Icons.forward_10,
                                      size: 30,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : HexColor("#114A70")),
                                ),
                                onPressed: () {
                                  MediaPlayer.shared.toggleSeek();
                                }),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Slider(
                            value: sliderValue,
                            // // : MyTheme.isDark
                            //     ? Colors.white
                            //     : HexColor("#114A70"),
                            activeColor: MyTheme.isDark
                                ? Colors.white
                                : HexColor("#114A70"),
                            inactiveColor: MyTheme.isDark
                                ? Colors.grey.withOpacity(0.5)
                                : HexColor('#6D94A9'),
                            onChanged: (value) {
                              sliderValue = value;
                              setState(() {});
                            },
                            onChangeStart: (value) {
                              isSliderDragging = true;
                            },
                            onChangeEnd: (value) {
                              isSliderDragging = false;
                              sliderValue = value;
                              setState(() {});

                              MediaPlayer.shared.seekAtsliderValue(value);
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTime,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                Spacer(),
                                Text(
                                  totalTime,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            Text(
                              "1x",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: MyTheme.isDark
                                    ? Colors.white
                                    : HexColor("#114A70"),
                              ),
                            ),
                            Spacer(),
                            FavouriteEpisodeButton(
                                MediaPlayer.shared.currentPlayingEpisode),
                            SizedBox(width: 30),
                            DownloadEpisodeButton(
                                MediaPlayer.shared.currentPlayingEpisode),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
