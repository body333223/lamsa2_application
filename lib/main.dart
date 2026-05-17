import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'core/widgets/whatsapp_notification_ui.dart';
import 'firebase_options.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/firestore_service.dart';
import 'services/image_upload_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'services/chat_notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'lamsa_notifications',
  'إشعارات لمسة',
  description: 'إشعارات التطبيق',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling a background message: ${message.messageId}");
  // Note: FCM messages with 'notification' payload are automatically displayed
  // by the system when the app is in background. No need to show local notification here.
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Deduplication: prevent showing same notification multiple times
final Set<String> shownNotifications = {};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler — يمنع الشاشة السوداء
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };

  // نشغل التطبيق فوراً — مش نستنى Firebase
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // تشيك الاتصال (سريع — مش بيعلق)
  final hasInternet = await ConnectivityService.checkInitialConnectivity();

  // نحاول نعمل Firebase init — لو فشل أو علق، التطبيق يكمل
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
    firebaseReady = true;

    // Enable unlimited Firestore offline cache
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firebase init error (app will continue): $e");
  }

  // Notifications — فقط لو Firebase جاهز
  if (firebaseReady) {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Create notification channel for background notifications
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  // Firebase Messaging — فقط لو فيه إنترنت و Firebase جاهز
  if (hasInternet && firebaseReady) {
    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Unsubscribe from ALL topics — notifications come via user token only
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all');
        await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
        await FirebaseMessaging.instance.unsubscribeFromTopic('android');
        await FirebaseMessaging.instance.unsubscribeFromTopic('ios');
      } catch (_) {}

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final data = message.data;

        final title =
            (notification?.title ?? data['title'] ?? '').toString().trim();
        final body =
            (notification?.body ?? data['body'] ?? '').toString().trim();

        if (title.isEmpty && body.isEmpty) return;

        // Deduplication — same content within 10 seconds = skip
        final contentKey = '${title}_$body';
        if (shownNotifications.contains(contentKey)) return;
        shownNotifications.add(contentKey);
        Future.delayed(const Duration(seconds: 10), () {
          shownNotifications.remove(contentKey);
        });

        // Show in-app overlay only (no system notification when app is open)
        showOverlayNotification((context) {
          return WhatsAppNotificationUI(
            title: title.isNotEmpty ? title : 'إشعار جديد',
            message: body.isNotEmpty ? body : 'لديكِ إشعار جديد',
            onTap: () {
              OverlaySupportEntry.of(context)?.dismiss();
            },
          );
        }, duration: const Duration(seconds: 4));
      });
    } catch (e) {
      debugPrint("Firebase Messaging init error: $e");
    }
  }

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
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => ImageUploadService()),
        ChangeNotifierProxyProvider2<FirestoreService, AuthService,
            ChatNotificationService>(
          lazy: false,
          create: (context) => ChatNotificationService(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, firestore, auth, previous) =>
              previous ?? ChatNotificationService(firestore, auth),
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
                  child: OverlaySupport.global(
                    child: ConnectivityWrapper(child: child!),
                  ),
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
