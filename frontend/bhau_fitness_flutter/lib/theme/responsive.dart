import 'package:flutter/material.dart';

/// Breakpoints for the web build. Below [tablet], every screen keeps its
/// original phone-first layout untouched. At or above [tablet], landing
/// sections switch to multi-column grids; at or above [desktop], shells
/// switch from bottom nav to a side rail.
class Breakpoints {
  static const tablet = 720.0;
  static const desktop = 1080.0;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= tablet;
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= desktop;
}

/// Centers page content and caps its width on wide screens, matching the
/// HTML site's `.wrap { max-width: 1200px }` container pattern.
class ContentMaxWidth extends StatelessWidget {
  const ContentMaxWidth({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Lays children out in a single column below [Breakpoints.tablet], and in
/// an evenly-spaced row of [columns] above it. Each child gets equal width
/// in the row layout via [Expanded].
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 20,
    this.runSpacing = 20,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTablet(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: runSpacing),
            children[i],
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// A simple responsive grid: 1 column on phone, [tabletColumns] on tablet,
/// [desktopColumns] on desktop. Children are wrapped to equal-width cells.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 18,
    this.runSpacing = 18,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= Breakpoints.desktop
        ? desktopColumns
        : width >= Breakpoints.tablet
            ? tabletColumns
            : 1;

    if (columns == 1) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: runSpacing),
            children[i],
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: cellWidth, child: child),
          ],
        );
      },
    );
  }
}
