import 'package:flutter/material.dart';
import 'package:podcast_app/utility/app_theme.dart';

class CommonTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final Widget prefix;
  final onChanged;
  final int? lines;
  final Color fillColor;
  final bool isReadOnly;
  const CommonTextField(
      {this.hintText = "",
      this.isPassword = false,
      this.prefix = const SizedBox(),
      Key? key,
      this.onChanged,
      this.lines,
      this.fillColor = AppTheme.kWHITE,
      this.isReadOnly = false})
      : super(key: key);

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  //
  bool _isHidden = false;
  //
  @override
  void initState() {
    _isHidden = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        obscureText: _isHidden,
        readOnly: widget.isReadOnly,
        onChanged: widget.onChanged,
        minLines: widget.lines ?? 1,
        maxLines: widget.lines ?? 1,
        decoration: InputDecoration(
          fillColor: widget.isReadOnly ? AppTheme.kWHITE : widget.fillColor,
          filled: true,
          isDense: true,
          hintText: widget.hintText,
          prefixIcon: widget.prefix,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon:
                      Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isHidden = !_isHidden))
              : null,
          // border: OutlineInputBorder(),
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: AppTheme.kPRIMARY.withOpacity(0.2)),
          //   borderRadius: BorderRadius.circular(12),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: AppTheme.kPRIMARY.withOpacity(1)),
          //   borderRadius: BorderRadius.circular(12),
          // ),
        ));
  }
}
