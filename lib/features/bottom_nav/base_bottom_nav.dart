import 'package:flutter/cupertino.dart';

class BaseBottomNavigationData {
  final Widget screen;

  final Widget? icon;

  final Widget? selected_icon;

  final String title;

  final int? index;
  final bool? hideAppBar;

  BaseBottomNavigationData(
      {required this.screen,
        this.icon,
        this.selected_icon,
        this.title = '',
        this.index,
        this.hideAppBar});

  @override
  String toString() {
    return 'BaseListData(screen: $screen, icon: $icon, selected_icon: $selected_icon, title: $title, index: $index,hideAppBar: $hideAppBar)';
  }
}