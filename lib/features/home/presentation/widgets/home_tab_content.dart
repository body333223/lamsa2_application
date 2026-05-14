import 'package:flutter/material.dart';
import 'home_header.dart';
import 'services_list.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: ServicesList()),
        SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
