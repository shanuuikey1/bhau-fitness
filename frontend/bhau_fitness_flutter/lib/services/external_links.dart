import 'package:url_launcher/url_launcher.dart';
import '../brand_config.dart';

/// Contact details are now sourced from [activeTenant] in brand_config.dart.
/// Changing the active tenant automatically updates all deep-links here.
class BhauContact {
  static String get whatsappNumber => activeTenant.whatsappNumber;
  static String get phone         => activeTenant.contactPhone;
  static String get email         => activeTenant.contactEmail;
  static String get instagram     => activeTenant.instagramHandle;
  static String get mapsQuery     => activeTenant.mapsQuery;

  static Future<void> openWhatsApp([String? message]) async {
    final msg = message ?? activeTenant.whatsappGreeting;
    final uri = Uri.parse('https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(msg)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openMaps() async {
    final uri = Uri.parse(activeTenant.mapsUrl);
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
