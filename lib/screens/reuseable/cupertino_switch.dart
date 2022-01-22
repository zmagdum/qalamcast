import 'package:flutter/cupertino.dart';
import 'package:podcast_app/utility/app_theme.dart';

class CustomSwitch extends StatefulWidget {
  final double scale;
  final bool initialValue;
  final onChanged;
  const CustomSwitch(
      {Key? key, this.scale = 0.8, this.initialValue = false, this.onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _value = false;
  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale,
      child: CupertinoSwitch(
        
        activeColor: AppTheme.kAPP_YELLOW,
        onChanged: (data) {
          setState(() {
            _value = data;
          });
          widget.onChanged(data);
        },
        value: _value,
      ),
    );
  }
}
