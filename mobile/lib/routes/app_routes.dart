class AppRoutes {
  static const String splash = '/splash';
  static const String languageSelection = '/language-selection';
  static const String welcome = '/welcome';
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';

  // Main Tabs
  static const String home = '/home';
  static const String projects = '/projects';
  static const String myProperties = '/my-properties';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Home sub-routes
  static String offerDetails(String offerId) => '/offers/$offerId';

  static const String enquiry = '/enquiry';
  static String enquiryWithProject(String projectId) =>
      '/enquiry?projectId=$projectId';

  static const String siteVisit = '/site-visit';
  static String siteVisitWithProject(String projectId) =>
      '/site-visit?projectId=$projectId';

  static const String emiCalculator = '/emi-calculator';
  static const String about = '/about';
  static const String payment = '/payment';
  static const String paymentHistoryAuth = '/payment-history-auth';
  static const String paymentHistory = '/payment-history';

  static const String myEnquiries = '/my-enquiries';
  static const String mySiteVisits = '/my-site-visits';

  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String editProfile = '/edit-profile';
  static const String faq = '/faq';

  // Project
  static const String projectDetailsBase = '/project/:id';
  static String projectDetails(String projectId) => '/project/$projectId';

  static String virtualTour(String projectId, String url) =>
      '/project/$projectId/360-tour?url=${Uri.encodeComponent(url)}';

  static String plotAvailability(String projectId) =>
      '/project/$projectId/plots';
  static String plotDetails(String projectId, String plotId) =>
      '/project/$projectId/plots/$plotId';

  // My Properties
  static String bookingDetails(String plotId) => '/booking-details/$plotId';

  // Profile sub-routes
  static const String kyc = '/kyc';
  static const String support = '/support';
  static const String referral = '/referral';
  static const String referredUsers = '/referred-users';
}
