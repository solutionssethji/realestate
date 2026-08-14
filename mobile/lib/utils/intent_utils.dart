import 'package:url_launcher/url_launcher.dart';

class IntentUtils {
  static Future<bool> launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> launchWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> launchMaps(double lat, double lng, String address) async {
    // Geo intent works natively on Android/iOS Google Maps
    final url = 'geo:$lat,$lng?q=${Uri.encodeComponent(address)}';
    final fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      return await launchUrl(
        Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
}
