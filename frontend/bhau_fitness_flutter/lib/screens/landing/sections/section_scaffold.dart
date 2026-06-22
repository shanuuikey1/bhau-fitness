import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';

/// Shared "eyebrow + heading + subtitle, centered" header used by almost
/// every section in the HTML (`.shead`).
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.eyebrow, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Text(eyebrow, style: BhauText.eyebrow(), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(title, style: BhauText.display(fontSize: 32), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(subtitle!, style: BhauText.body(fontSize: 15), textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
    );
  }
}

/// Wraps a section in the standard vertical padding (`.sec-pad`) used
/// throughout the HTML layout, with an optional bottom divider.
class Section extends StatelessWidget {
  final Widget child;
  final Color? background;
  const Section({super.key, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: ContentMaxWidth(child: child),
    );
  }
}

/// Network image with a gradient skeleton placeholder, matching the HTML's
/// `.ph` loading look instead of Flutter's default grey box / spinner.
class BhauImage extends StatelessWidget {
  final String url;
  final double? height;
  final BorderRadius? radius;
  const BhauImage({super.key, required this.url, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(14),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13202A), Color(0xFF0C1116)],
          ),
        ),
        child: Image.network(
          url,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const SizedBox.shrink(),
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported_outlined, color: BhauColors.faint, size: 28),
          ),
        ),
      ),
    );
  }
}
