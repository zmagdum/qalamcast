import 'package:flutter/material.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/screens/reuseable/circle_button.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';

class MinimizePlayerView extends StatelessWidget {
  const MinimizePlayerView({
    Key key,
  }) : super(key: key);

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
                width: sizeData.screenSize.width,
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
                            "Hadith Intesive (A week-long song asdfadsfa fsdf asdfasdf asdrr)",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: IconButton(
                              icon: SvgPicture.asset(Images.PAUSE,
                                  color: MyTheme.isDark
                                      ? Colors.white
                                      : HexColor("#114A70")),
                              onPressed: () {
                                //
                                print("paused");
                              }),

                          // actionButton(Images.PAUSE, onTap: () {

                          // }),
                        ),
                        SizedBox(
                          width: 44,
                          child: IconButton(
                              icon: SvgPicture.asset(Images.BUFFERNEXT,
                                  color: MyTheme.isDark
                                      ? Colors.white
                                      : HexColor("#114A70")),
                              onPressed: () {
                                //
                                print("paused");
                              }),
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
