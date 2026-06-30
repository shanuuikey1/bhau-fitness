import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/animations.dart';

// =============================================================================
// ANIMATED SECTION HEADER — eyebrow + draw-underline + stagger title/subtitle
// =============================================================================
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.eyebrow, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 0),
            offsetY: 20,
            child: Text(eyebrow, style: BhauText.eyebrow(), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          // Animated gradient underline draws itself beneath eyebrow
          Center(
            child: AnimatedGradientLine(
              delay: const Duration(milliseconds: 150),
              maxWidth: 60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            offsetY: 24,
            child: Text(title, style: BhauText.display(fontSize: 32), textAlign: TextAlign.center),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 320),
              offsetY: 16,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(subtitle!,
                    style: BhauText.body(fontSize: 15), textAlign: TextAlign.center),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION WRAPPER
// =============================================================================
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

// =============================================================================
// NETWORK / ASSET IMAGE WITH GRADIENT PLACEHOLDER
// =============================================================================
class BhauImage extends StatelessWidget {
  final String url;
  final double? height;
  final BorderRadius? radius;
  final Alignment alignment;
  final BoxFit fit;

  const BhauImage({
    super.key,
    required this.url,
    this.height,
    this.radius,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(18),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13202A), Color(0xFF0C1116)],
          ),
        ),
        child: url.startsWith('http')
            ? Image.network(
                url,
                height: height,
                width: double.infinity,
                fit: fit,
                alignment: alignment,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox.shrink(),
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: BhauColors.faint, size: 28),
                ),
              )
            : Image.asset(
                url,
                height: height,
                width: double.infinity,
                fit: fit,
                alignment: alignment,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: BhauColors.faint, size: 28),
                ),
              ),
      ),
    );
  }
}
