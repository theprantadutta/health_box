import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Consistent Spacing Utilities for HealthBox UI
class HealthBoxSpacing {
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= HealthBoxDesignSystem.breakpointXl) {
      return EdgeInsets.all(HealthBoxDesignSystem.spacing8);
    } else if (width >= HealthBoxDesignSystem.breakpointLg) {
      return EdgeInsets.all(HealthBoxDesignSystem.spacing6);
    } else if (width >= HealthBoxDesignSystem.breakpointMd) {
      return EdgeInsets.all(HealthBoxDesignSystem.spacing5);
    } else {
      return EdgeInsets.all(HealthBoxDesignSystem.spacing4);
    }
  }

  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= HealthBoxDesignSystem.breakpointLg) {
      return HealthBoxDesignSystem.cardPaddingLg;
    } else if (width >= HealthBoxDesignSystem.breakpointMd) {
      return HealthBoxDesignSystem.cardPaddingBase;
    } else {
      return HealthBoxDesignSystem.cardPaddingBase;
    }
  }

  /// Standard section spacing
  static const EdgeInsets sectionPadding = EdgeInsets.all(
    HealthBoxDesignSystem.spacing4,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(
    HealthBoxDesignSystem.spacing4,
  );
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: HealthBoxDesignSystem.spacing4,
    vertical: HealthBoxDesignSystem.spacing2,
  );

  /// Content spacing helpers
  static const SizedBox xs = SizedBox(height: HealthBoxDesignSystem.spacing1);
  static const SizedBox sm = SizedBox(height: HealthBoxDesignSystem.spacing2);
  static const SizedBox md = SizedBox(height: HealthBoxDesignSystem.spacing3);
  static const SizedBox lg = SizedBox(height: HealthBoxDesignSystem.spacing4);
  static const SizedBox xl = SizedBox(height: HealthBoxDesignSystem.spacing6);
  static const SizedBox xxl = SizedBox(height: HealthBoxDesignSystem.spacing8);
}

/// Typography utilities for consistent text styling
class HealthBoxTextStyle {
  static TextStyle getDisplayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!;
  }

  static TextStyle getDisplayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!;
  }

  static TextStyle getDisplaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!;
  }

  static TextStyle getHeadlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!;
  }

  static TextStyle getHeadlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!;
  }

  static TextStyle getHeadlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!;
  }

  static TextStyle getTitleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  static TextStyle getTitleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  static TextStyle getTitleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!;
  }

  static TextStyle getBodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }

  static TextStyle getBodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  static TextStyle getBodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }

  static TextStyle getLabelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!;
  }

  static TextStyle getLabelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!;
  }

  static TextStyle getLabelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!;
  }
}
