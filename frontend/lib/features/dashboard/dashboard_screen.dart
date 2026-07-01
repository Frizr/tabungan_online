import 'package:tabungan_frontend/features/dashboard/models/tab_icon_data.dart';

import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'app_theme.dart';
import 'home/home_screen.dart';
import 'home/add_transaction_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: AppTheme.background,
  );

  @override
  void initState() {
    for (var tab in tabIconsList) {
      tab.isSelected = false;
    }
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = HomeScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            showDialog(
              context: context,
              builder: (context) => AddTransactionDialog(),
            );
          },
          changeIndex: (int index) {
            animationController?.reverse().then<dynamic>((data) {
              if (!mounted) {
                return;
              }
              setState(() {
                if (index == 0) {
                  tabBody =
                      HomeScreen(animationController: animationController);
                } else {
                  // Placeholder for other tabs
                  tabBody = Center(
                    child: Text(
                      'Fitur ${['Dashboard', 'Statistik', 'Laporan', 'Profil'][index]} sedang dikembangkan.',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppTheme.darkText,
                      ),
                    ),
                  );
                }
              });
            });
          },
        ),
      ],
    );
  }
}
