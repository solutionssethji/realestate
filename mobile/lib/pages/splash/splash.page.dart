import 'dart:async';
import 'package:customer_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import '../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final token = appBox.get('authToken');
        final isProfileComplete = appBox.get('isProfileComplete') ?? false;

        if (token != null) {
          if (isProfileComplete) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.register);
          }
        } else {
          context.go(AppRoutes.login);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: .6,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(controller);

    final opacity = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, .4),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, data) {
            return FadeTransition(
              opacity: opacity,
              child: ScaleTransition(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1800),
                      builder: (_, value, child) {
                        return Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.midnightNavy.withValues(
                                  alpha: .35 * value,
                                ), // Using midnightNavy-like color
                                blurRadius: 55,
                                spreadRadius: 12,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      width: 200,
                      child: Image.asset('assets/logo.png'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
