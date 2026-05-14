import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/home_controller.dart';
import '../../../bookings/presentation/pages/my_bookings_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_tab_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    final screens = <Widget>[
      const HomeTabContent(),
      MyBookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: controller.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: controller.currentIndex,
        onTap: controller.changeTab,
      ),
    );
  }
}
