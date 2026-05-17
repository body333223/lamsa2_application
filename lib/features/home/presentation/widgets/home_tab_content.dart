import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'home_header.dart';
import 'services_list.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  Future<void> _onRefresh() async {
    // Small delay to show the refresh animation
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      displacement: 60,
      strokeWidth: 2.5,
      child: const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: HomeHeader()),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: ServicesList()),
          SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
