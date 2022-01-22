import 'package:flutter/material.dart';

enum DeviceScreenType { Mobile, Tablet }

class SizingInformation {
  final Orientation? orientation;
  final DeviceScreenType? deviceType;
  final Size? screenSize;
  final EdgeInsets? padding;
  final Size? localWidgetSize;

  SizingInformation({
    this.orientation,
    this.deviceType,
    this.screenSize,
    this.padding,
    this.localWidgetSize,
  });
  @override
  String toString() {
    return 'Orientation:$orientation, DeviceType:$deviceType, ScreenSize:$screenSize, LocalWidgetSize:$localWidgetSize';
  }
}
