import 'package:flutter/material.dart';

class KeyedWidget extends StatelessWidget {
  final int index;
  final Widget child;

  const KeyedWidget({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
