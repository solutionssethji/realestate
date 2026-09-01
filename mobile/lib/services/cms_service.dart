import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/services/api_service.dart';
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
    logApi(function: 'getContactInfo()', request: {'langCode': langCode});
    try {
      final aboutDoc = await _db
          .collection('setting')
          .doc('aboutCompany')
          .get();
      final contactDoc = await _db.collection('setting').doc('contactUs').get();

      final about = aboutDoc.exists ? aboutDoc.data() ?? {} : {};
      final contact = contactDoc.exists ? contactDoc.data() ?? {} : {};

      final whyChooseUsRaw = _getBilingual(about['whyChooseUs'], langCode);
      final whyChooseUsList = whyChooseUsRaw.isEmpty
          ? <String>[]
          : whyChooseUsRaw
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

      final response = CompanyInfo(
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

      logApi(function: 'getContactInfo()', response: response.toString());
      return response;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getContactInfo()',
      );
      rethrow;
    }
  }

  /// Fetches the configured Currency from Firebase.
  static Future<Map<String, String>> getCurrencyConfig() async {
    logApi(function: 'getCurrencyConfig()', request: {});
    try {
      final doc = await _db.collection('setting').doc('currencyConfig').get();
      if (doc.exists && doc.data() != null) {
        final currency = doc.data()!;
        if (currency.isNotEmpty) {
          final response = {
            'code': currency['code']?.toString() ?? 'INR',
            'symbol': currency['symbol']?.toString() ?? '₹',
            'name': currency['name']?.toString() ?? 'Indian Rupee',
          };
          logApi(function: 'getCurrencyConfig()', response: response);
          return response;
        }
      }

      final defaultResponse = {
        'code': 'INR',
        'symbol': '₹',
        'name': 'Indian Rupee',
      };
      logApi(function: 'getCurrencyConfig()', response: defaultResponse);
      return defaultResponse;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getCurrencyConfig()',
      );
      logApi(function: 'getCurrencyConfig()', error: e.toString());
    }
    return {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'};
  }

  /// Fetches legal/public content like terms or privacy.
  static Future<Map<String, String>?> getPublicContent(String langCode) async {
    logApi(function: 'getPublicContent()', request: {'langCode': langCode});
    try {
      final doc = await _db.collection('setting').doc('legalPolicies').get();
      if (doc.exists && doc.data() != null) {
        final legal = doc.data()!;
        final response = {
          'termsAndConditions': _getBilingual(
            legal['termsAndConditions'],
            langCode,
          ),
          'privacyPolicy': _getBilingual(legal['privacyPolicy'], langCode),
        };
        logApi(function: 'getPublicContent()', response: response);
        return response;
      }
      logApi(function: 'getPublicContent()', response: null);
      return null;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getPublicContent()',
      );

      rethrow;
    }
  }

  /// Fetches active FAQs ordered by sortOrder.
  static Future<List<Map<String, dynamic>>> getFaqs() async {
    logApi(function: 'getFaqs()', request: {});
    try {
      final qs = await _db
          .collection('faqs')
          .where('active', isEqualTo: true)
          .get();
      final response = qs.docs.map((e) => e.data()).toList();
      logApi(function: 'getFaqs()', response: response);
      return response;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getFaqs()');

      rethrow;
    }
  }
}
