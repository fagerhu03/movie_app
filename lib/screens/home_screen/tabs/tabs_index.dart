// lib/screens/home_screen/tabs/tabs_index.dart
import 'package:flutter/material.dart';

enum AppTab { home, search, library, profile }

class TabsController extends ChangeNotifier {
  final pageCtrl = PageController();
  int index = 0;

  void setIndex(int i) {
    index = i;
    notifyListeners();
  }

  void jumpTo(int i) {
    index = i;
    pageCtrl.jumpToPage(i);
    notifyListeners();
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }
}
