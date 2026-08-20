import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_info.dart';

/// Centralized service to fetch CMS and settings from Firebase.
class CmsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String _getBilingual(dynamic field, String langCode) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) {
      return (field[langCode] ?? field['en'] ?? '').toString();
    }
    return '';
  }

  /// Fetches global Contact and About settings.
  static Future<CompanyInfo?> getContactInfo(String langCode) async {
    try {
      final doc = await _db.collection('setting').doc('global').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final about = data['aboutCompany'] ?? {};
        final contact = data['contactUs'] ?? {};

        final whyChooseUsRaw = _getBilingual(about['whyChooseUs'], langCode);
        final whyChooseUsList = whyChooseUsRaw.isEmpty 
            ? <String>[] 
            : whyChooseUsRaw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        return CompanyInfo(
          name: 'Shubhaytanam', // Or add this to DB later
          about: _getBilingual(about['companyProfile'], langCode),
          vision: _getBilingual(about['vision'], langCode),
          mission: _getBilingual(about['mission'], langCode),
          whyChooseUs: whyChooseUsList,
          officeAddress: _getBilingual(contact['officeLocation'], langCode),
          latitude: (contact['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (contact['longitude'] as num?)?.toDouble() ?? 0.0,
          phone: contact['directCall']?.toString() ?? '',
          whatsapp: contact['whatsapp']?.toString() ?? '',
          email: contact['email']?.toString() ?? '',
          googleMapsUrl: contact['googleMaps']?.toString() ?? '',
          contactNumberDisplay: _getBilingual(contact['contactNumber'], langCode),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the configured Currency from Firebase.
  static Future<Map<String, String>> getCurrencyConfig() async {
    try {
      final doc = await _db.collection('setting').doc('global').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final currency = data['currencyConfig'] ?? {};
        if (currency.isNotEmpty) {
          return {
            'code': currency['code']?.toString() ?? 'INR',
            'symbol': currency['symbol']?.toString() ?? '₹',
            'name': currency['name']?.toString() ?? 'Indian Rupee',
          };
        }
      }
    } catch (e) {
      // Ignore and fallback
    }
    return {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'};
  }

  /// Fetches legal/public content like terms or privacy.
  static Future<Map<String, String>?> getPublicContent(String langCode) async {
    try {
      final doc = await _db.collection('setting').doc('global').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final legal = data['legalPolicies'] ?? {};
        return {
          'termsAndConditions': _getBilingual(legal['termsAndConditions'], langCode),
          'privacyPolicy': _getBilingual(legal['privacyPolicy'], langCode),
        };
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
