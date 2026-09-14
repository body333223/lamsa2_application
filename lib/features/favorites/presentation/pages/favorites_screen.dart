// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../models/service_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../widgets/favorite_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ServiceModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = context.read<DataService>();
      final services = await data.getFavoriteServices(auth.userId!);
      setState(() {
        _favorites = services;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String serviceId) async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) return;

    setState(() {
      _favorites.removeWhere((s) => s.id == serviceId);
    });

    try {
      final data = context.read<DataService>();
      await data.toggleFavorite(auth.userId!, serviceId);
    } catch (_) {
      // Revert on error
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          s.favorites,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child:
                GlowOrb(size: 300, color: AppColors.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child:
                GlowOrb(size: 400, color: AppColors.accent.withOpacity(0.08)),
          ),
          if (_isLoading)
            ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 100, 20, 40),
              itemCount: 3,
              itemBuilder: (_, __) => _ShimmerCard(isDark: isDark),
            )
          else if (_favorites.isEmpty)
            _buildEmptyState(context, s)
          else
            RefreshIndicator(
              onRefresh: _loadFavorites,
              color: AppColors.primary,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 100, 20, 120),
                itemCount: _favorites.length,
                itemBuilder: (context, i) {
                  return FavoriteCard(
                    service: _favorites[i],
                    onRemove: () => _removeFavorite(_favorites[i].id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppStrings s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded,
                color: AppColors.primary.withOpacity(0.4), size: 60),
          ),
          const SizedBox(height: 24),
          Text(
            s.noFavorites,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.addFavoritesHint,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final bool isDark;
  const _ShimmerCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
    );
  }
}
