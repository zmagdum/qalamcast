import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color kTRANSPARENT = Colors.transparent;
  static const Color kAPP_BLUE = Color(0xff126088);
  static const Color kAPP_YELLOW = Color(0xffEDB831);
  static const Color kAPP_GREY = Color(0xff959595);
  static const Color kSEARCH_GREY = Color(0xffd8d8d8);
  static const Color kTEXT_GREY = Color(0xff8f8f8f);
  static const Color kBACK_GREY = Color(0xfff1f1f1);
  // static const Color kDIVIDER_GREY = Color(0xff979797);
  static const Color kBOTOM_NAV_DARK = Color(0xff191a30);
  static const Color kWHITE = Colors.white;
  static const Color kAPP_BLACK = Color(0xff00000b);
  static const Color kBLACK = Colors.black;
  static const Color kGREY = Colors.grey;
  static const Color kGREEN = Colors.green;

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: kWHITE,
    primaryColor: kAPP_BLUE, //app logo color
    secondaryHeaderColor: kAPP_BLACK, //texts and icons
    colorScheme: ColorScheme(
        surface: kWHITE, //bottom navigation bar color
        onSurface: kAPP_GREY, //bottom navigation bar icon color
        primary: kAPP_GREY, //divider color
        primaryVariant: kSEARCH_GREY.withOpacity(0.36), //searchbar background color
        secondary: kTEXT_GREY, //secondary texts and icons grey
        secondaryVariant: kTRANSPARENT,
        background: kTRANSPARENT,
        error: kTRANSPARENT,
        onPrimary: kTRANSPARENT,
        onSecondary: kTRANSPARENT,
        onBackground: kTRANSPARENT,
        onError: kTRANSPARENT,
        brightness: Brightness.light),
    appBarTheme: AppBarTheme(color: kWHITE, elevation: 0, centerTitle: true, iconTheme: IconThemeData(color: kBLACK, size: 25)),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: kAPP_BLACK,
    primaryColor: kWHITE, //app logo color
    secondaryHeaderColor: kWHITE, //texts and icons
    colorScheme: ColorScheme(
        surface: kBOTOM_NAV_DARK, //bottom navigation bar color
        onSurface: kWHITE, //bottom navigation bar icon color
        primary: kWHITE.withOpacity(0.36), //divider color
        primaryVariant: kBOTOM_NAV_DARK, //searchbar background color
        secondary: kWHITE, //secondary texts and icons grey
        secondaryVariant: kTRANSPARENT,
        background: kTRANSPARENT,
        error: kTRANSPARENT,
        onPrimary: kTRANSPARENT,
        onSecondary: kTRANSPARENT,
        onBackground: kTRANSPARENT,
        onError: kTRANSPARENT,
        brightness: Brightness.dark),
    appBarTheme:
        AppBarTheme(color: kAPP_BLACK, elevation: 0, centerTitle: true, iconTheme: IconThemeData(color: kBLACK, size: 25)),
  );
}


class MyTheme with ChangeNotifier {
  MyTheme() {
    print("Called!");
  }
  static bool isDark = false;

  ThemeMode currentTheme() {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

MyTheme currentTheme = MyTheme();
