import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    required this.icon,
    required this.selectedIcon,
    this.index = 0,
    this.isSelected = false,
    this.animationController,
  });

  IconData icon;
  IconData selectedIcon;
  bool isSelected;
  int index;

  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}
