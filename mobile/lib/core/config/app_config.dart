import '../../models/company_info.dart';

class AppConfig {
  static CompanyInfo getCompanyInfo() {
    return const CompanyInfo(
      name: 'Unic Real Estate',
      about:
          'Unic Real Estate is a premier property development company dedicated to transforming land into premium gated communities. With a track record of delivering 15+ successful projects over the last decade, we bring transparency and quality to land investment.',
      vision:
          'To be the most trusted name in real estate, offering sustainable and high-appreciating land investments across the country.',
      mission:
          'To deliver clear-title, legally vetted, and fully developed plots that serve as the perfect foundation for our customers\' dream homes.',
      whyChooseUs: [
        '100% Clear Titles & RERA Approved',
        'Strategic Locations with High ROI',
        'End-to-End Documentation Support',
        'Premium Infrastructure & Amenities',
        'Transparent Pricing with No Hidden Costs',
      ],
      officeAddress: '101, Unic Tower, Viman Nagar, Pune, Maharashtra 411014',
      latitude: 18.5679,
      longitude: 73.9143,
      phone: '+919876543210',
      whatsapp: '+919876543210',
      email: 'contact@unicrealestate.com',
    );
  }
}
