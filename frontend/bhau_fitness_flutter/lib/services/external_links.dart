import 'package:url_launcher/url_launcher.dart';

/// Same WhatsApp number / contact details used throughout bhau_fitness_v3.html
/// (demo placeholder number, not a real line).
class BhauContact {
  static const whatsappNumber = '919876543210';
  static const phone = '+91 98765 43210';
  static const email = 'shanuuikey1@gmail.com';
  static const instagram = 'hackthealgorithm.in';
  static const mapsQuery = 'Parasia,Chhindwara,Madhya+Pradesh';

  static Future<void> openWhatsApp([String message = 'Hi BHAU FITNESS!']) async {
    final uri = Uri.parse('https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openMaps() async {
    final uri = Uri.parse('https://maps.google.com/?q=$mapsQuery');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openPhone() async {
    final uri = Uri.parse('tel:$whatsappNumber');
    await launchUrl(uri);
  }

  static Future<void> openEmail() async {
    final uri = Uri.parse('mailto:$email');
    await launchUrl(uri);
  }

  static Future<void> openInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/$instagram');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
