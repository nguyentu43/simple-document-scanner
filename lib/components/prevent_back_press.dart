import 'package:flutter/material.dart';

class PreventBackPress extends StatelessWidget {
  Widget child;
  PreventBackPress({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: child, onWillPop: () => Future.value(false));
  }
}
