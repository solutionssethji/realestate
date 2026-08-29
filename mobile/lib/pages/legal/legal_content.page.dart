import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/generic_shimmer_loader.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import 'legal_content.logic.dart';

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
    final state = ref.watch(legalContentLogicProvider(documentId));

    return Scaffold(
      appBar: PremiumAppBar(title: fallbackTitle),
      body: SafeArea(child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, state) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }

    if (state.isError) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Error loading content',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final content = state.content;

    if (content == null || content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.article_outlined,
                size: 64,
                color: AppTheme.neutral400,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.fallbackTitleUnavailable(fallbackTitle),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.black54),
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
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.6, color: AppTheme.black),
          ),
        ],
      ),
    );
  }
}
