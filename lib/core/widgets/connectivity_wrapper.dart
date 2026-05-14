import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';
import '../theme/app_theme.dart';

/// Wraps the app content. When connectivity is lost, shows a full-screen
/// "No Internet" overlay that completely replaces the child widget to avoid
/// any rendering errors from network-dependent widgets underneath.
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityService>().isConnected;

    if (!isConnected) {
      return const _NoInternetOverlay();
    }

    return child;
  }
}

class _NoInternetOverlay extends StatefulWidget {
  const _NoInternetOverlay();

  @override
  State<_NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<_NoInternetOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    await context.read<ConnectivityService>().checkConnectivity();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? Colors.white : AppColors.primary)
                            .withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 56,
                        color: isDark ? Colors.white70 : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    Text(
                      'لا يوجد اتصال بالإنترنت',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      'يرجى التحقق من اتصالك بالإنترنت\nوالمحاولة مرة أخرى',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white60 : AppColors.textMedium,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Retry button
                    SizedBox(
                      width: 220,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isRetrying ? null : _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isRetrying
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
