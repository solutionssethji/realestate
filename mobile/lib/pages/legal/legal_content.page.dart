import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import '../../services/cms_service.dart';
import '../../widgets/generic_shimmer_loader.dart';
import '../../utils/l10n_extension.dart';
import '../../config/locale_provider.dart';

class LegalContentPage extends ConsumerWidget {
  final String documentId; // 'terms' or 'privacy'
  final String fallbackTitle;

  const LegalContentPage({
    super.key,
    required this.documentId,
    required this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: fallbackTitle),
      body: FutureBuilder<Map<String, String>?>(
        future: CmsService.getPublicContent(currentLocale.languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoader();
          }

          final data = snapshot.data;
          
          final contentKey = documentId == 'terms' ? 'termsAndConditions' : 'privacyPolicy';
          final content = data?[contentKey];

          if (content == null || content.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.fallbackTitleUnavailable(fallbackTitle),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fallbackTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
