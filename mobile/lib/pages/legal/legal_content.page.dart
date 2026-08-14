import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import '../../services/cms_service.dart';
import '../../utils/localized_string.dart';
import '../../widgets/generic_shimmer_loader.dart';
import '../../utils/l10n_extension.dart';

class LegalContentPage extends StatelessWidget {
  final String documentId; // 'terms' or 'privacy'
  final String fallbackTitle;

  const LegalContentPage({
    super.key,
    required this.documentId,
    required this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(title: fallbackTitle),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: CmsService.getPublicContent(documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoader();
          }

          final data = snapshot.data;

          if (data == null || data['published'] != true) {
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

          final title = getLocalizedText(
            context,
            data['title'],
            defaultVal: fallbackTitle,
          );
          final content = getLocalizedText(
            context,
            data['content'],
            defaultVal: '',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
