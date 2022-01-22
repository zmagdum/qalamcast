import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podcast_app/AudioPlayer/audio_player_manager.dart';
import 'package:podcast_app/custom_navigator/custom_scaffold.dart';
import 'package:podcast_app/models/sizing_info.dart';
import 'package:podcast_app/screens/dashboard/podcast_series.dart';
import 'package:podcast_app/screens/dashboard/settings.dart';
import 'package:podcast_app/screens/minimize_player_view.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/base_widget.dart';
import 'package:podcast_app/utility/constants.dart';
// import 'package:custom_navigator/custom_scaffold.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import '../player_full_screen.dart';
import 'home.dart';
import 'library.dart';

late StreamController miniPlayerUIManager;
var isMiniPlayerVisible = false;
late BuildContext topContext;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int _currentIndex = 0;
  List<Widget> _pages = [
    HomePage(),
    PodcastSeries(),
    Library(),
    Container(),
    // WebView(
    //     initialUrl: "https://www.qalam.institute/support-us",
    //     javascriptMode: JavascriptMode.unrestricted),
    Settings()
  ];

  @override
  void initState() {
    super.initState();

    miniPlayerUIManager = StreamController.broadcast();

    miniPlayerUIManager.stream.listen((event) {
      if (event == 1) {
        // show miniplayer
        isMiniPlayerVisible = true;
      } else if (event == 2) {
        // hide miniplayer
        isMiniPlayerVisible = false;
      } else if (event == 3) {
        isMiniPlayerVisible = false;

        Navigator.push(
          topContext,
          MaterialPageRoute(
            builder: (context) => PlayerFullScreen(episodes: MediaPlayer.shared.episodes, index: MediaPlayer.shared.currenItemIndex,),
          ),
        );
      } else if (event == 4) {
        // hide and stop player
        MediaPlayer.shared.togglePlaying(forcePause: true);
        isMiniPlayerVisible = false;

      }
      setState(() {});
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeData) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              CustomScaffold(
                onItemTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _pages,
                scaffold: Scaffold(
                    bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  showUnselectedLabels: true,
                  items: [
                    getNavigationIcon(Images.iHOME, Strings.HOME, 0, sizeData),
                    getNavigationIcon(
                        Images.iPODCAST, Strings.SERIES, 1, sizeData),
                    getNavigationIcon(
                        Images.iLIBRARY, Strings.LIBRARY, 2, sizeData),
                    getNavigationIcon(
                        Images.iDONATE, Strings.DONATE, 3, sizeData),
                    getNavigationIcon(
                        Images.iSETTINGS, Strings.SETTINGS, 4, sizeData),
                  ],
                )),
              ),
              if (isMiniPlayerVisible)
                GestureDetector(
                  excludeFromSemantics: true,
                  onTap: () {
                    // show full player
                    miniPlayerUIManager.add(3);
                  },
                  onVerticalDragEnd: (e) {
                    print(e);
                    if (e.velocity.pixelsPerSecond.dy > 350) {
                      // hide miniplayer
                      miniPlayerUIManager.add(4);
                    }
                  },
                  child: MinimizePlayerView(),
                )
            ],
          ),
        ),
      );
    });
  }

  getNavigationIcon(image, name, idx, SizingInformation sizeData) {
    Color getSelectedColor(idx) {
      if (_currentIndex == idx)
        return AppTheme.kAPP_YELLOW;
      else
        return Theme.of(context).colorScheme.onSurface;
    }

    return BottomNavigationBarItem(
      backgroundColor: Theme.of(context).colorScheme.surface,
      icon: SvgPicture.asset(image,
          color: getSelectedColor(idx), height: 28, width: 25),
      title: Text(
        name,
        style: TextStyle(color: getSelectedColor(idx)),
      ),
    );
  }
}
