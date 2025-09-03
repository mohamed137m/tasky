import 'package:flutter/material.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  const CustomCheckBoxWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final Function(bool?) onChanged;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xff15B86C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(3),
      ),
      side: Theme.of(context).checkboxTheme.side,
    );
  }
}
