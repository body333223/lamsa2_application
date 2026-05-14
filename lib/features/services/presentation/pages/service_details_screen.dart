// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/service_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/locale_service.dart';
import '../widgets/service_book_bar.dart';
import '../widgets/service_hero_image.dart';
import '../widgets/service_includes_list.dart';
import '../widgets/service_info_section.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isFav = false;
  bool _favLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      setState(() => _favLoading = false);
      return;
    }
    final isFav = await context
        .read<FirestoreService>()
        .isFavorite(uid, widget.service.id);
    if (mounted) {
      setState(() {
        _isFav = isFav;
        _favLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) return;
    setState(() => _isFav = !_isFav);
    await context
        .read<FirestoreService>()
        .toggleFavorite(uid, widget.service.id);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleService>().isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final service = widget.service;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ServiceHeroImage(
                imageUrl: service.imageUrl,
                isArabic: isArabic,
                isDark: isDark,
                isFav: _isFav,
                favLoading: _favLoading,
                onBack: () => Navigator.pop(context),
                onToggleFavorite: _toggleFavorite,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ServiceInfoSection(
                        service: service,
                        isArabic: isArabic,
                      ),
                      const SizedBox(height: 28),
                      ServiceIncludesList(isArabic: isArabic),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ServiceBookBar(
            service: service,
            isArabic: isArabic,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
