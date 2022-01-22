import 'package:flutter/material.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/routes.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/constants.dart';
import 'package:podcast_app/AudioPlayer/audio_player_manager.dart';
import 'package:podcast_app/AudioPlayer/audio_player_manager.dart';
import 'package:audio_service/audio_service.dart';

void main() async {
  // await setupServiceLocator();
  runApp(QalamCast());
}

GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

class QalamCast extends StatefulWidget {
  const QalamCast({Key? key}) : super(key: key);

  @override
  _QalamCastState createState() => _QalamCastState();
}

class _QalamCastState extends State<QalamCast> {
  //
  @override
  void initState() {
    super.initState();
    SqliteDatabaseManager.shared.createTables();

    // if (Platform.isAndroid) Webview.platform = SurfaceAndroidWebView();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: mainNavigatorKey,
      title: Strings.APP_NAME,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentTheme.currentTheme(),
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.dashboard,
    );
  }
}
