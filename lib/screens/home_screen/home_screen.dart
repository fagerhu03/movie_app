// lib/screens/home_screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'tabs/tabs_index.dart';
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
  final controller = TabsController();
  final yellow = const Color(0xFFF6BD00);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _navImg(String path, Color color) {
    return Image.asset(
      path,
      width: 28,
      height: 28,
      // for PNGs: apply a solid tint
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: const Color(0xFF121312),
          body: SafeArea(
            child: PageView(
              controller: controller.pageCtrl,
              onPageChanged: controller.setIndex,
              children: const [
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
                indicatorColor: Color(0xFF282A28).withOpacity(.15),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                // iconTheme is ignored because we’re providing custom widgets
              ),
              child: NavigationBar(
                height: 64.h,
                selectedIndex: controller.index,
                onDestinationSelected: controller.jumpTo,
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
      },
    );
  }
}
