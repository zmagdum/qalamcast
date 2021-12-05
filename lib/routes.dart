import 'package:flutter/material.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';
import 'package:podcast_app/screens/splash/splash.dart';

class Routes {
  static const String dashboard = '/dashboard';
  // static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => Dashboard());
      // case login:
      //   return MaterialPageRoute(builder: (_) => Login());
    }
    return MaterialPageRoute(builder: (_) => Container());
  }
}
