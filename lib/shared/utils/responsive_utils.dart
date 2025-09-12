import 'package:flutter/material.dart';

enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

enum ScreenOrientation {
  portrait,
  landscape,
}

class ResponsiveUtils {
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 1200.0;
  
  static const double compactMaxWidth = 600.0;
  static const double mediumMaxWidth = 840.0;
  static const double expandedMinWidth = 1240.0;

  static ScreenSize getScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMaxWidth) {
      return ScreenSize.mobile;
    } else if (screenWidth < tabletMaxWidth) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  static ScreenOrientation getScreenOrientation(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? ScreenOrientation.portrait
        : ScreenOrientation.landscape;
  }

  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  static bool isPortrait(BuildContext context) {
    return getScreenOrientation(context) == ScreenOrientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return getScreenOrientation(context) == ScreenOrientation.landscape;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }

  static int getGridCrossAxisCount(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileColumns;
      case ScreenSize.tablet:
        return tabletColumns;
      case ScreenSize.desktop:
        return desktopColumns;
    }
  }

  static double getCardMaxWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    
    if (screenWidth < compactMaxWidth) {
      return screenWidth - 32.0;
    } else if (screenWidth < mediumMaxWidth) {
      return 400.0;
    } else {
      return 480.0;
    }
  }

  static Widget buildResponsiveLayout({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile ?? tablet ?? desktop ?? const SizedBox.shrink();
      case ScreenSize.tablet:
        return tablet ?? desktop ?? mobile ?? const SizedBox.shrink();
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
  }

  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getGridCrossAxisCount(
          context,
          mobileColumns: mobileColumns,
          tabletColumns: tabletColumns,
          desktopColumns: desktopColumns,
        ),
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  static Widget buildResponsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? getCardMaxWidth(context),
      ),
      padding: padding ?? getResponsivePadding(context),
      margin: margin,
      child: child,
    );
  }

  static Widget buildResponsiveSafeArea({
    required BuildContext context,
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left && !isDesktop(context),
      right: right && !isDesktop(context),
      child: child,
    );
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double mobileScale = 1.0,
    double tabletScale = 1.1,
    double desktopScale = 1.2,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return baseFontSize * mobileScale;
      case ScreenSize.tablet:
        return baseFontSize * tabletScale;
      case ScreenSize.desktop:
        return baseFontSize * desktopScale;
    }
  }

  static bool shouldShowDrawer(BuildContext context) {
    return isMobile(context);
  }

  static bool shouldShowRail(BuildContext context) {
    return !isMobile(context);
  }

  static NavigationRailLabelType getNavigationRailLabelType(
    BuildContext context,
  ) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return NavigationRailLabelType.none;
      case ScreenSize.tablet:
        return NavigationRailLabelType.selected;
      case ScreenSize.desktop:
        return NavigationRailLabelType.all;
    }
  }

  static double getNavigationRailWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return 56.0;
      case ScreenSize.tablet:
        return 72.0;
      case ScreenSize.desktop:
        return 80.0;
    }
  }

  static int getListViewItemsPerRow(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    
    if (screenWidth < compactMaxWidth) {
      return 1;
    } else if (screenWidth < mediumMaxWidth) {
      return 2;
    } else {
      return 3;
    }
  }

  static bool isCompactScreen(BuildContext context) {
    return getScreenWidth(context) < compactMaxWidth;
  }

  static bool isMediumScreen(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    return screenWidth >= compactMaxWidth && screenWidth < expandedMinWidth;
  }

  static bool isExpandedScreen(BuildContext context) {
    return getScreenWidth(context) >= expandedMinWidth;
  }
}