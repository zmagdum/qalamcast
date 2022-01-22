import 'package:flutter/material.dart';
import 'package:podcast_app/models/sizing_info.dart';
import 'package:podcast_app/utility/utils.dart';

class BaseWidget extends StatelessWidget {
  final Widget Function(
      BuildContext context, SizingInformation sizingInformation)? builder;
  const BaseWidget({Key? key, this.builder}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, boxSizing) {
      var sizingInformation = SizingInformation(
        orientation: mediaQuery.orientation,
        deviceType: Utils.getDeviceType(mediaQuery),
        padding: mediaQuery.padding,
        screenSize: mediaQuery.size,
        localWidgetSize: Size(boxSizing.maxWidth, boxSizing.maxHeight),
      );
      return builder!(context, sizingInformation);
    });
  }
}
