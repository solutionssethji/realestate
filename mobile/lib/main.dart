import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'config/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'theme/theme.dart';
import 'routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_routes.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

late Box appBox;

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

bool _isSyncingFcmToken = false;

Future<void> syncCurrentUserFcmToken() async {
  if (_isSyncingFcmToken) return;
  _isSyncingFcmToken = true;

  try {
    final user = AuthService.currentUser;
    if (user == null) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) return;

    await ApiService.updateUserProfile(user.uid, {
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('Error syncing FCM token: $e');
  } finally {
    _isSyncingFcmToken = false;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  if (data['type'] == 'NEW_OFFER' || data['type'] == 'OFFER') {
    final offerId = data['offerId'];
    if (offerId != null && rootNavigatorKey.currentContext != null) {
      GoRouter.of(rootNavigatorKey.currentContext!).push(AppRoutes.offerDetails(offerId));
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  appBox = await Hive.openBox('appBox');

  if (!kIsWeb) {
    // Crashlytics removed
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    debugPrint('Foreground push notification received: ${message.messageId}');
  });

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message);
  });

  // Handle notification tap when app is terminated
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // We defer the routing slightly to ensure the router is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNotificationTap(initialMessage);
    });
  }

  FirebaseAnalytics.instance;
  AuthService.authStateChanges().listen((user) async {
    if (user != null && user.emailVerified) {
      await syncCurrentUserFcmToken();
    }
  });

  runApp(const ProviderScope(child: RealEstateApp()));
}

class RealEstateApp extends HookConsumerWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
              Breakpoint(start: 801, end: 1920, name: DESKTOP),
              Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
        );
      },
    );
  }
}
