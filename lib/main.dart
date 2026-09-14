import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/data_service.dart';
import 'features/services/domain/repositories/services_repository.dart';
import 'features/services/data/repositories/services_repository_impl.dart';
import 'features/bookings/domain/repositories/bookings_repository.dart';
import 'features/bookings/data/repositories/bookings_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/support/domain/repositories/chat_repository.dart';
import 'features/support/data/repositories/chat_repository_impl.dart';
import 'services/image_upload_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'services/chat_notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Check connectivity
  final hasInternet = await ConnectivityService.checkInitialConnectivity();

  runApp(LamsaApp(initiallyConnected: hasInternet));
}

class LamsaApp extends StatelessWidget {
  final bool initiallyConnected;

  const LamsaApp({super.key, required this.initiallyConnected});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ConnectivityService(initiallyConnected: initiallyConnected),
        ),
        ChangeNotifierProvider(create: (_) => LocaleService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<ServicesRepository>(create: (_) => ServicesRepositoryImpl()),
        Provider<BookingsRepository>(create: (_) => BookingsRepositoryImpl()),
        Provider<FavoritesRepository>(create: (_) => FavoritesRepositoryImpl()),
        Provider<NotificationsRepository>(
            create: (_) => NotificationsRepositoryImpl()),
        Provider<ChatRepository>(create: (_) => ChatRepositoryImpl()),
        Provider<DataService>(
          create: (context) => DataService(
            servicesRepository: context.read<ServicesRepository>(),
            bookingsRepository: context.read<BookingsRepository>(),
            favoritesRepository: context.read<FavoritesRepository>(),
            notificationsRepository: context.read<NotificationsRepository>(),
            chatRepository: context.read<ChatRepository>(),
          ),
        ),
        Provider(create: (_) => ImageUploadService()),
        ChangeNotifierProxyProvider<AuthService, ChatNotificationService>(
          lazy: false,
          create: (context) => ChatNotificationService(
            null,
            context.read<AuthService>(),
          ),
          update: (context, auth, previous) =>
              previous ?? ChatNotificationService(null, auth),
        ),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleService>().locale;
          final themeMode = context.watch<ThemeService>().themeMode;

          return MaterialApp(
            title: 'لمسه',
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            debugShowMaterialGrid: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final isArabic = context.watch<LocaleService>().isArabic;
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: ConnectivityWrapper(child: child!),
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
