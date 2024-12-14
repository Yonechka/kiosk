// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class IconbuttonWidget extends StatelessWidget {
  final VoidCallback function;
  final IconData iconData;

  const IconbuttonWidget({
    super.key,
    required this.function,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: function,
      icon: Icon(
        iconData,
      ),
    );
  }
}
