import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import '../../utils/localized_string.dart';
import '../../widgets/generic_shimmer_loader.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import 'faq.logic.dart';

class FaqPage extends HookConsumerWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(faqLogicProvider);
    // ignore: unused_local_variable
    final logic = ref.read(faqLogicProvider.notifier);

    return Scaffold(
      appBar: PremiumAppBar(title: loc.faq),
      body: SafeArea(child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, state) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }

    if (state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    final faqs = state.faqs;

    if (faqs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                context.l10n.noFaqsAvailable,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final faq = faqs[index];
        final question = getLocalizedText(
          context,
          faq['question'],
          defaultVal: context.l10n.questionUnavailable,
        );
        final answer = getLocalizedText(
          context,
          faq['answer'],
          defaultVal: context.l10n.answerUnavailable,
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              childrenPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
