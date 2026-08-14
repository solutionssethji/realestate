import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_info.dart';

/// Centralized service to fetch CMS and settings from Firebase.
class CmsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches global Contact settings.
  static Future<CompanyInfo?> getContactInfo() async {
    try {
      final doc = await _db.collection('appSettings').doc('contact').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return CompanyInfo(
          name: data['companyName']?.toString() ?? 'Unic Real Estate',
          about:
              data['about']?.toString() ??
              'A premier property development company.',
          vision:
              data['vision']?.toString() ??
              'To be the most trusted name in real estate.',
          mission:
              data['mission']?.toString() ??
              'To deliver clear-title, legally vetted plots.',
          whyChooseUs: List<String>.from(
            data['whyChooseUs'] ??
                [
                  '100% Clear Titles & RERA Approved',
                  'Strategic Locations with High ROI',
                ],
          ),
          officeAddress: data['officeAddress']?.toString() ?? '',
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          phone: data['phone']?.toString() ?? '',
          whatsapp: data['whatsapp']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the configured Currency from Firebase.
  /// Falls back to INR if not set.
  static Future<Map<String, String>> getCurrencyConfig() async {
    try {
      final doc = await _db.collection('appSettings').doc('currency').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'code': data['code']?.toString() ?? 'INR',
          'symbol': data['symbol']?.toString() ?? '₹',
          'name': data['name']?.toString() ?? 'Indian Rupee',
        };
      }
    } catch (e) {
      // Ignore and fallback
    }
    return {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'};
  }

  /// Fetches legal/public content like terms or privacy.
  static Future<Map<String, dynamic>?> getPublicContent(String docId) async {
    try {
      final doc = await _db.collection('publicContent').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Fetches active FAQs ordered by sortOrder.
  static Future<List<Map<String, dynamic>>> getFaqs() async {
    try {
      final qs = await _db
          .collection('faqs')
          .where('active', isEqualTo: true)
          .orderBy('sortOrder')
          .get();
      return qs.docs.map((e) => e.data()).toList();
    } catch (e) {
      return [];
    }
  }
}
