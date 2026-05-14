// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/smart_image.dart';

class PromoBanner extends StatelessWidget {
  final bool isDark;

  const PromoBanner({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Query without orderBy to avoid composite index requirement
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sliders')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerBanner(isDark: isDark);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort client-side instead of Firestore orderBy
        final sliders = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aOrder = (aData['order'] ?? 0) as num;
            final bOrder = (bData['order'] ?? 0) as num;
            return aOrder.compareTo(bOrder);
          });

        return SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: sliders.length,
            controller: PageController(viewportFraction: 1.0),
            itemBuilder: (context, index) {
              final data = sliders[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartImage(
                        imageData: imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Title text
                      if (title.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 60,
                          child: Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ShimmerBanner extends StatelessWidget {
  final bool isDark;
  const _ShimmerBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
