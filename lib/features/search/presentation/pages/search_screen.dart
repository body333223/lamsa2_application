// ignore_for_file: deprecated_member_use, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../models/service_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../widgets/search_card.dart';
import '../widgets/search_header.dart';

class SearchScreen extends StatefulWidget {
  final String initialCategory;
  const SearchScreen({super.key, required this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.initialCategory.isEmpty ? 'all' : widget.initialCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getCategories(AppStrings strings) {
    return [
      {'key': 'all', 'label': strings.all},
      {'key': 'مساج', 'label': strings.massage},
      {'key': 'حمام مغربي', 'label': strings.moroccanBath},
      {'key': 'بادكير ومنكير', 'label': strings.pedicureManicure},
      {'key': 'الباقات', 'label': strings.packages},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final localeService = context.watch<LocaleService>();
    final strings = AppStrings(context);
    final isArabic = localeService.isArabic;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child:
                GlowOrb(size: 200, color: AppColors.primary.withOpacity(0.1)),
          ),
          Column(
            children: [
              SearchHeader(
                controller: _ctrl,
                focusNode: _focusNode,
                query: _query,
                isArabic: isArabic,
                selectedCategory: _selectedCategory,
                categories: _getCategories(strings),
                onQueryChanged: (v) => setState(() => _query = v),
                onCategorySelected: (key) =>
                    setState(() => _selectedCategory = key),
                onClear: () {
                  _ctrl.clear();
                  setState(() => _query = '');
                },
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: FutureBuilder<List<ServiceModel>>(
                  future: firestoreService.searchServices(
                    _query,
                    _selectedCategory == 'all' ? 'الكل' : _selectedCategory,
                  ),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: 3,
                        itemBuilder: (_, __) => _ShimmerSearchCard(),
                      );
                    }
                    final results = snap.data ?? [];
                    if (results.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: const Center(
                                child:
                                    Text('🔍', style: TextStyle(fontSize: 40))),
                          ),
                          const SizedBox(height: 24),
                          Text(strings.noResults,
                              style: GoogleFonts.cairo(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(strings.tryDifferentSearch,
                              style: GoogleFonts.cairo(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5))),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: results.length,
                      itemBuilder: (_, i) => SearchCard(service: results[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerSearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
