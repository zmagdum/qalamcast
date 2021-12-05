import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:podcast_app/screens/reuseable/circle_button.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';

class PlayerFullScreen extends StatefulWidget {
  const PlayerFullScreen({Key key}) : super(key: key);

  @override
  _PlayerFullScreenState createState() => _PlayerFullScreenState();
}

class _PlayerFullScreenState extends State<PlayerFullScreen> {
  var sliderValue = 0.0;
  var totalTime = "5:00";
  var remainingTime = "0:00";

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
                            left: 20, right: 20, top: 30, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            actionButton(Images.BUFFERBACK, onTap: () {}),
                            actionButton(Images.BACK, onTap: () {}),
                            actionButton(Images.PAUSE, onTap: () {}),
                            actionButton(Images.NEXT, onTap: () {}),
                            actionButton(Images.BUFFERNEXT, onTap: () {}),
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
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  totalTime,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: MyTheme.isDark
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                Spacer(),
                                Text(
                                  remainingTime,
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
                            actionButton(Images.HEART, onTap: () {}),
                            SizedBox(width: 30),
                            actionButton(Images.DOWNLOAD1, onTap: () {}),
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
