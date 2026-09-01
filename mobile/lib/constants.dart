/// Application-level constants.
///
/// Contains ONLY public, non-sensitive values.
/// Secrets (payment keys, signing passwords, Firebase admin keys)
/// must NEVER appear here.
class AppConstants {
  // ── App Identity ───────────────────────────────────────────────────────────
  static const String appName = 'Shubhaytanam Connect';
  static const String appVersion = '1.0.0';

  // ── Localization ───────────────────────────────────────────────────────────
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'hi'];

  // ── Firestore Collection Names ─────────────────────────────────────────────
  static const String colProjects = 'projects';
  static const String colPlots = 'plots';
  static const String colOffers = 'offers';
  static const String colEnquiries = 'enquiries';
  static const String colSiteVisits = 'siteVisits';
  static const String colPayments = 'payments';
  static const String colAdmins = 'admins';
  static const String colCompanyInfo = 'companyInfo';

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const int projectsPageSize = 20;
  static const int plotsPageSize = 50;
  static const int offersPageSize = 20;
  static const int adminListPageSize = 25;

  // ── Local Storage Keys ─────────────────────────────────────────────────────
  static const String localeKey = 'app_locale';

  // ── Contact (placeholder — update when client provides real values) ─────────
  static const String contactEmail = 'contact@elysium.com';
  static const String officeAddress =
      '101, Elysium Tower, Viman Nagar, Pune, Maharashtra 411014';
      
  // ── External Links ─────────────────────────────────────────────────────────
  static const String privacyPolicyUrl = 'https://www.example.com/privacy-policy';
  static const String termsConditionsUrl = 'https://www.example.com/terms';
  static const String faqsUrl = 'https://www.example.com/faqs';

  // ── Environment Setup ──────────────────────────────────────────────────────

  static const String paymentEnv = String.fromEnvironment(
    'PAYMENT_ENV',
    defaultValue: 'sandbox',
  );

  static const String paymentPublicKey = String.fromEnvironment(
    'PAYMENT_PUBLIC_KEY',
    defaultValue: '',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyA5AapPl3wZ3r6Hz5Uz4cVrWu_s8iHASRc',
  );
}
