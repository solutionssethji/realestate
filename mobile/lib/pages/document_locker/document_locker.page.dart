import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';
import '../../../utils/l10n_extension.dart';
import '../../widgets/error_state.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/skeleton_list.dart';
import '../../theme/spacing.dart';
import '../../theme/theme.dart';
import '../../utils/snackbar_utils.dart';

class DocumentLockerPage extends HookConsumerWidget {
  const DocumentLockerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = useState<List<Map<String, dynamic>>>([]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    Future<void> loadDocuments() async {
      isLoading.value = true;
      errorMessage.value = null;
      final uid = AuthService.currentUser?.uid;
      if (uid == null) {
        isLoading.value = false;
        return;
      }
      try {
        documents.value = await ApiService.getUserDocuments(uid);
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> openDocument(String? url) async {
      final uri = url == null ? null : Uri.tryParse(url);
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          AppSnackbar.showError(context, context.l10n.unableToOpenDocument);
        }
      }
    }

    useEffect(() {
      loadDocuments();
      return null;
    }, const []);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.documentVault),
      body: isLoading.value
          ? SkeletonList(
              itemCount: 4,
              spacing: AppSpacing.sm,
              itemBuilder: (_, __) => const DocumentListTileSkeleton(),
            )
          : errorMessage.value != null
          ? ErrorState(message: errorMessage.value, onRetry: loadDocuments)
          : documents.value.isEmpty
          ? Center(child: Text(context.l10n.noAdminDocuments))
          : ListView.builder(
              itemCount: documents.value.length,
              itemBuilder: (context, index) {
                final document = documents.value[index];
                return ListTile(
                  leading: const Icon(Icons.description, color: AppTheme.info),
                  title: Text(document['name'] ?? context.l10n.legalDocument),
                  subtitle: Text(document['type'] ?? context.l10n.pdfFile),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => openDocument(
                      (document['url'] ??
                              document['downloadUrl'] ??
                              document['fileUrl'])
                          ?.toString(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
