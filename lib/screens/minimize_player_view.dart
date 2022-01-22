import 'package:flutter/material.dart';
import 'package:podcast_app/AudioPlayer/audio_player_manager.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/screens/reuseable/circle_button.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';

class MinimizePlayerView extends StatefulWidget {
  const MinimizePlayerView({
    Key? key,
  }) : super(key: key);

  @override
  _MinimizePlayerViewState createState() => _MinimizePlayerViewState();
}

class _MinimizePlayerViewState extends State<MinimizePlayerView> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeData) {
      return Container(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 52),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                width: sizeData.screenSize!.width,
                height: 90,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, -2)),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0, left: 8, bottom: 12),
                  child: Center(
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            MediaPlayer.shared.currentPlayingEpisode!.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Center(
                            child: IconButton(
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
                          ),

                        ),
                        SizedBox(
                          width: 44,
                          child: Center(
                            child: IconButton(
                                icon: Icon(Icons.forward_10,
                                    size: 30,
                                    color: MyTheme.isDark
                                        ? Colors.white
                                        : HexColor("#114A70")),
                                onPressed: () {
                                  //
                                  MediaPlayer.shared.toggleSeek();
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 20,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, -2)),
                    ]),
              )
            ],
          ),
        ),
      );
    });
  }
}
