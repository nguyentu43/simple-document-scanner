import 'package:flutter/material.dart';
import 'package:simple_document_scanner/constants/tabs.dart';

class TabProvider extends ChangeNotifier {
  MyTab _tab = MyTab.home;

  MyTab get tab => _tab;

  void changeTab(MyTab tab) {
    _tab = tab;
    notifyListeners();
  }
}
