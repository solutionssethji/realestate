import 'package:customer_app/utils/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:customer_app/main.dart';
import 'package:customer_app/routes/app_routes.dart';
import 'package:customer_app/theme/theme.dart';
import 'package:customer_app/widgets/background_painters.widget.dart';
import 'package:customer_app/config/locale_provider.dart';

class LanguageSelectionPage extends HookConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final selectedLang = useState<String>(currentLocale.languageCode);
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: BottomLeftDotsPainter())),
          Positioned.fill(child: CustomPaint(painter: TopRightWavePainter())),
          Positioned.fill(
            child: CustomPaint(painter: BottomRightCirclesPainter()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    [
                          const SizedBox(height: 80),
                          Text(
                            l10n.chooseLanguage,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.selectLanguageDesc,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          _LanguageCard(
                            title: "English",
                            subtitle: "English",
                            isSelected: selectedLang.value == 'en',
                            onTap: () {
                              selectedLang.value = 'en';
                              ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale('en');
                            },
                          ),
                          const SizedBox(height: 16),
                          _LanguageCard(
                            title: "हिंदी",
                            subtitle: "Hindi",
                            isSelected: selectedLang.value == 'hi',
                            onTap: () {
                              selectedLang.value = 'hi';
                              ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale('hi');
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale(selectedLang.value);
                              appBox.put('hasSelectedLanguage', true);
                              if (context.mounted) {
                                context.go(AppRoutes.welcome);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              l10n.continueBtn,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ]
                        .animate(interval: 50.ms)
                        .fade(duration: 500.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),
              ),
            ),
          ),
        ],
      ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  title.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
