import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/library_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  final yellow = const Color(0xFFF6BD00);

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Widget _navImg(String path, Color color) {
    return Image.asset(
      path,
      width: 28,
      height: 28,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _index = i),
          children: [
            HomeTab(),
            SearchTab(),
            LibraryTab(),
            ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF282A28),
            indicatorColor: const Color(0xFF282A28).withOpacity(.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          ),
          child: NavigationBar(
            height: 64.h,
            selectedIndex: _index,
            onDestinationSelected: (i) {
              setState(() => _index = i);
              _pageCtrl.jumpToPage(i);
            },
            destinations: [
              NavigationDestination(
                icon: _navImg('assets/icons/home.png', Colors.white),
                selectedIcon: _navImg('assets/icons/home.png', yellow),
                label: 'Home',
              ),
              NavigationDestination(
                icon: _navImg('assets/icons/search.png', Colors.white),
                selectedIcon: _navImg('assets/icons/search.png', yellow),
                label: 'Search',
              ),
              NavigationDestination(
                icon: _navImg('assets/icons/library.png', Colors.white),
                selectedIcon: _navImg('assets/icons/library.png', yellow),
                label: 'Library',
              ),
              NavigationDestination(
                icon: _navImg('assets/icons/profile.png', Colors.white),
                selectedIcon: _navImg('assets/icons/profile.png', yellow),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
