import 'package:flutter/material.dart';
import 'package:podcast_app/models/sizing_info.dart';
import 'package:podcast_app/utility/app_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final SizingInformation sizeData;
  final double? radius;
  final onTap;
  const CircleButton(
      {required this.icon,
      required this.sizeData,
      this.radius,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: radius ?? MediaQuery.of(context).size.height * 0.038,
        width: radius ?? MediaQuery.of(context).size.height * 0.038,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: AppTheme.kBLACK,
              spreadRadius: 10,
              blurRadius: 2,
              offset: Offset(0, 0))
        ]),
        child: Material(
          color: Colors.white, // Button color
          child: InkWell(
            // splashColor: Colors.red, // Splash color
            onTap: onTap,
            child: Icon(icon,
                color: AppTheme.kAPP_BLUE,
                size: MediaQuery.of(context).size.height * 0.028),
          ),
        ),
      ),
    );
  }
}

Widget actionButton(String icon, {Function? onTap}) {
  return GestureDetector(
    onTap: onTap as void Function()?,
    child: Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(5),
      child: SvgPicture.asset(icon,
          color: MyTheme.isDark ? Colors.white : HexColor("#114A70")),
    ),
  );
}
