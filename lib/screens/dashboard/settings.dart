import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podcast_app/screens/reuseable/cupertino_switch.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:podcast_app/utility/constants.dart';

import 'dashboard.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  StreamSubscription playerEventSub;

  @override
  void initState() {
    super.initState();
    topContext = context;

    playerEventSub = miniPlayerUIManager.stream.listen((event) {
      Future.delayed(Duration(milliseconds: 100)).then((e) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    playerEventSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var mainColor = Theme.of(context).secondaryHeaderColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Const.HORIZONTAL_PADDING),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            leading: SizedBox(),
            title: Image.asset(Images.APP_LOGO,
                height: 35, color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: 15),
          Text(Strings.SETTINGS,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: mainColor)),
          SizedBox(height: 15),
          ListTile(
            dense: true,
            leading: SvgPicture.asset(Images.DARK_MODE,
                height: 25, width: 25, fit: BoxFit.fill, color: mainColor),
            title: Text(Strings.DARK_MODE,
                style: TextStyle(fontSize: 16, color: mainColor)),
            trailing: CustomSwitch(
                initialValue: MyTheme.isDark,
                onChanged: (data) => currentTheme.switchTheme()),
          ),
          Divider(color: Theme.of(context).colorScheme.primary),
          ListTile(
              dense: true,
              leading: SvgPicture.asset(Images.LANGUAGE,
                  height: 25, width: 25, fit: BoxFit.fill, color: mainColor),
              title: Text(Strings.LANGUAGE,
                  style: TextStyle(fontSize: 16, color: mainColor))),
          Divider(color: Theme.of(context).colorScheme.primary),
          ListTile(
              dense: true,
              leading: SvgPicture.asset(Images.NOTIFICATION,
                  height: 25, width: 25, fit: BoxFit.fill, color: mainColor),
              title: Text(Strings.NOTIFICATIONS,
                  style: TextStyle(fontSize: 16, color: mainColor))),
          Divider(color: Theme.of(context).colorScheme.primary),
          ListTile(
              dense: true,
              leading: SvgPicture.asset(Images.VOLUME,
                  height: 25, width: 25, fit: BoxFit.fill, color: mainColor),
              title: Text(Strings.VOLUME,
                  style: TextStyle(fontSize: 16, color: mainColor))),
        ],
      ),
    );
  }
}
