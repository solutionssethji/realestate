import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:customer_app/services/version_service.dart';
import 'package:customer_app/routes/routes.dart';
import 'package:customer_app/widgets/update_page.dart';

class VersionCheckWrapper extends HookWidget {
  final Widget child;

  const VersionCheckWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final hasCheckedUpdates = useRef(false);

    useEffect(() {
      final listener = AppLifecycleListener(
        onStateChange: (state) {
          if (state == AppLifecycleState.resumed && !hasCheckedUpdates.value) {
            hasCheckedUpdates.value = true;
            _checkUpdates(context);
          }
        },
      );

      // Also check immediately on first build if we are resumed
      final initialState = WidgetsBinding.instance.lifecycleState;
      if (initialState == AppLifecycleState.resumed &&
          !hasCheckedUpdates.value) {
        hasCheckedUpdates.value = true;
        // Wait for Splash Screen GoRouter.go() to finish so it doesn't wipe our dialog
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            _checkUpdates(context);
          }
        });
      }

      return listener.dispose;
    }, []);

    return child;
  }

  Future<void> _checkUpdates(BuildContext context) async {
    final versionService = VersionService();
    final result = await versionService.checkForUpdates();

    if (result.updateType == UpdateType.none || result.config == null) return;

    if (!context.mounted) return;

    final storeUrl = Platform.isAndroid
        ? result.config!.androidUrl
        : result.config!.iosUrl;

    rootNavigatorKey.currentState?.push(
      PageRouteBuilder(
        opaque: true, // true because it's a full page Scaffold
        pageBuilder: (context, animation, secondaryAnimation) =>
            UpdatePageWidget(
              isForceUpdate: result.updateType == UpdateType.force,
              storeUrl: storeUrl,
              latestVersion: result.config!.latestVersion,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
