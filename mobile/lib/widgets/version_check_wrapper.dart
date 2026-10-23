import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:customer_app/routes/routes.dart';
import 'package:customer_app/services/version_service.dart';
import 'package:customer_app/widgets/maintenance_page.dart';
import 'package:customer_app/widgets/update_page.dart';

class VersionCheckWrapper extends HookWidget {
  final Widget child;

  const VersionCheckWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDialogOpen = useRef(false);

    useEffect(() {
      final listener = AppLifecycleListener(
        onStateChange: (state) {
          if (state == AppLifecycleState.resumed && !isDialogOpen.value) {
            _checkUpdates(context, isDialogOpen);
          }
        },
      );

      // Guaranteed first check on all devices (wait 2.5s for splash & route transition)
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (context.mounted && !isDialogOpen.value) {
          _checkUpdates(context, isDialogOpen);
        }
      });

      return listener.dispose;
    }, []);

    return child;
  }

  Future<void> _checkUpdates(
    BuildContext context,
    ObjectRef<bool> isDialogOpen,
  ) async {
    final versionService = VersionService();
    final result = await versionService.checkForUpdates();

    if (result.updateType == UpdateType.none || result.config == null) return;

    if (!context.mounted) return;

    isDialogOpen.value = true;

    if (result.updateType == UpdateType.maintenance) {
      await rootNavigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              MaintenancePageWidget(
                message: result.config!.maintenanceMessage,
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
      isDialogOpen.value = false;
      return;
    }

    final storeUrl = Platform.isAndroid
        ? result.config!.androidUrl
        : result.config!.iosUrl;

    await rootNavigatorKey.currentState?.push(
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
    isDialogOpen.value = false;
  }
}
