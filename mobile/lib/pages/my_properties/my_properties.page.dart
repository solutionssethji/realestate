import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/l10n_extension.dart';
import 'my_properties.logic.dart';

class MyPropertiesPage extends HookConsumerWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(myPropertiesLogicProvider);
    final l10n = context.l10n;

    if (user == null) {
      return Scaffold(
        appBar: PremiumAppBar(title: l10n.myProperties),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.pleaseLoginToViewProperties),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: Text(l10n.loginBtn),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.myProperties),
      body: _buildBody(state, context, l10n),
    );
  }

  Widget _buildBody(dynamic state, BuildContext context, dynamic l10n) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.properties.isEmpty) {
      return Center(
        child: Text(l10n.noPropertiesYet),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.properties.length,
      itemBuilder: (context, index) {
        final data = state.properties[index];
        final plotId = data['id'];
        final projectName = data['projectName'] ?? 'Unknown Project';
        final plotNumber = data['plotNumber'] ?? 'Unknown Plot';
        final status = data['status'] ?? 'Unknown';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.bookmark, size: 40, color: Colors.blue),
            title: Text(
              projectName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(context.l10n.plotNoLabel(plotNumber.toString())),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'SOLD'
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'SOLD'
                          ? Colors.green.shade800
                          : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/my-properties/$plotId/emi-tracker');
            },
          ),
        );
      },
    );
  }
}
