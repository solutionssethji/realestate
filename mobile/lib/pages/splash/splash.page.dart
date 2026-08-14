import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants.dart';
import '../../utils/l10n_extension.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn),
      ),
    );

    useEffect(() {
      animationController.forward().then((_) {
        // Navigate to home after animation
        if (context.mounted) {
          context.go('/home');
        }
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Opacity(
          opacity: fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Logo Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  size: 50,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.reinventingRealEstate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                context.l10n.luxuryRealEstate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
