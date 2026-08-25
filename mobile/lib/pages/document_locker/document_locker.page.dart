import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DocumentLockerPage extends ConsumerStatefulWidget {
  const DocumentLockerPage({super.key});

  @override
  ConsumerState<DocumentLockerPage> createState() => _DocumentLockerPageState();
}

class _DocumentLockerPageState extends ConsumerState<DocumentLockerPage> {
  List<Map<String, dynamic>> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final docs = await ApiService.getUserDocuments(uid);
      setState(() {
        documents = docs;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Vault')),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : documents.isEmpty
          ? const Center(child: Text('No documents uploaded by Admin yet.'))
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return ListTile(
                  leading: const Icon(Icons.description, color: Colors.blue),
                  title: Text(doc['name'] ?? 'Legal Document'),
                  subtitle: Text(doc['type'] ?? 'PDF'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // Implement download using url launcher or similar
                    },
                  ),
                );
              },
            )
    );
  }
}
