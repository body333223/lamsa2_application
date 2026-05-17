// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../offers/presentation/pages/offer_details_screen.dart';

/// Slider/Carousel widget that displays active promo banners from Firestore.
/// Reads from the "sliders" collection where isActive == true, ordered by "order".
class PromoBanner extends StatelessWidget {
  final bool isDark;

  const PromoBanner({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
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

        // Sort client-side by 'order' field to avoid needing a composite index
        final sliders = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aOrder =
                ((a.data() as Map<String, dynamic>)['order'] ?? 0) as num;
            final bOrder =
                ((b.data() as Map<String, dynamic>)['order'] ?? 0) as num;
            return aOrder.compareTo(bOrder);
          });

        return SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: sliders.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (context, index) {
              final data = sliders[index].data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString().trim();
              final imageUrl = (data['imageUrl'] ?? '').toString().trim();
              final subtitle = (data['subtitle'] ?? '').toString().trim();
              final serviceId = (data['serviceId'] ?? '').toString().trim();
              final type = (data['type'] ?? 'offer').toString().trim();

              // Skip sliders without image
              if (imageUrl.isEmpty) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfferDetailsScreen(
                        title: title,
                        imageUrl: imageUrl,
                        subtitle: subtitle,
                        serviceId: serviceId,
                        type: type,
                        data: data,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SmartImage(
                          imageData: imageUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 18,
                          right: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
