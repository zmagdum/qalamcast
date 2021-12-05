import 'package:flutter/material.dart';
import 'package:podcast_app/models/sizing_info.dart';

class Utils {
  //get current device orientation and device size category
  static DeviceScreenType getDeviceType(MediaQueryData mediaQuery) {
    var orientation = mediaQuery.orientation;
    double deviceWidth = 0;
    if (orientation == Orientation.landscape) {
      deviceWidth = mediaQuery.size.height;
    } else {
      deviceWidth = mediaQuery.size.width;
    }
    if (deviceWidth > 600) {
      return DeviceScreenType.Tablet;
    }
    return DeviceScreenType.Mobile;
  }
}
