import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Filled button with the cyan→lime brand gradient instead of a flat color —
/// ElevatedButton can't paint a gradient background directly, so this wraps
/// one in a gradient-filled, clipped container instead.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.height = 52,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient ?? const LinearGradient(colors: [BhauColors.limeDeep, BhauColors.lime]),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(color: BhauColors.bg, fontWeight: FontWeight.w700, fontSize: 15),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass card with a soft brand-colored glow around the border — used for
/// the login/auth card. A plain BoxShadow glow reads as "premium" without
/// needing a custom shader.
class GlowCard extends StatelessWidget {
  const GlowCard({super.key, required this.child, this.padding, this.maxWidth});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: padding ?? const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: BhauColors.bg.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: BhauColors.lime.withValues(alpha: 0.75), width: 1.4),
          boxShadow: [
            BoxShadow(color: BhauColors.lime.withValues(alpha: 0.45), blurRadius: 30, spreadRadius: 0),
            BoxShadow(color: BhauColors.lime.withValues(alpha: 0.16), blurRadius: 70, spreadRadius: -6),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// "BHAU" in plain white + "FITNESS" in solid lime — the split-color
/// wordmark treatment used on the login card and elsewhere.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 30});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('BHAU ', style: BhauText.display(fontSize: fontSize)),
        Text('FITNESS', style: BhauText.display(fontSize: fontSize, color: BhauColors.lime)),
      ],
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  const _HexagonClipper();

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// The hexagonal "BB" crossed-dumbbell brand mark used above the login card.
class HexagonLogo extends StatelessWidget {
  const HexagonLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipPath(
            clipper: const _HexagonClipper(),
            child: Container(
              color: BhauColors.bg,
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: BhauColors.lime, width: 2),
              ),
            ),
          ),
          Icon(Icons.fitness_center, color: BhauColors.lime, size: size * 0.42),
        ],
      ),
    );
  }
}
