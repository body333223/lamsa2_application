// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../services/auth_service.dart';
import '../../logic/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_stats_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final authService = context.watch<AuthService>();
    final controller = ProfileController(authService: authService);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: controller.isGuest
          ? _buildGuestView(s)
          : _buildUserView(controller, s, authService),
    );
  }

  Widget _buildGuestView(AppStrings s) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(name: s.guest, email: '', bookings: 0),
        ),
        SliverToBoxAdapter(child: ProfileMenu(name: '')),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildUserView(
      ProfileController controller, AppStrings s, AuthService authService) {
    final photoUrl = authService.currentUser?.photoURL;

    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getUserData(),
      builder: (_, snap) {
        final data = snap.data;
        final name = (data?['name'] ?? '') as String;
        final email = (data?['email'] ?? '') as String;

        return StreamBuilder<QuerySnapshot>(
          stream: controller.bookingsStream(),
          builder: (_, bookSnap) {
            final bookingCount = bookSnap.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: controller.favoritesStream(),
              builder: (_, favSnap) {
                final favCount = favSnap.data?.docs.length ?? 0;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProfileHeader(
                        name: name.isEmpty ? s.guest : name,
                        email: email,
                        bookings: bookingCount,
                        photoUrl: photoUrl,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ProfileStatsRow(
                        bookings: bookingCount,
                        favorites: favCount,
                      ),
                    ),
                    SliverToBoxAdapter(child: ProfileMenu(name: name)),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
