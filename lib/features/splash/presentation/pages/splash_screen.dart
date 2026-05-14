// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          await Permission.notification.request();
        }
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint("Notification permission request failed: $e");
    }
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    await _requestNotificationPermission();

    try {
      final auth = context.read<AuthService>();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) =>
              auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                        const Color(0xFF2C1E22),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFAF6F7),
                        AppColors.primaryLight.withOpacity(0.4),
                      ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: _GlowingOrb(
              size: 350,
              color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.2),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _GlowingOrb(
              size: 300,
              color: AppColors.accent.withOpacity(isDark ? 0.1 : 0.15),
            ),
          ),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 48,
                              color:
                                  isDark ? Colors.white : AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Lamsa',
                            style: GoogleFonts.cairo(
                              fontSize: 54,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textDark,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Luxury Wellness at Your Doorstep',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color:
                                  (isDark ? Colors.white : AppColors.textMedium)
                                      .withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: 60,
                            height: 2,
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  (isDark ? Colors.white : AppColors.primary)
                                      .withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowingOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
