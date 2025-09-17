import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common_transitions.dart';

/// Stagger animation utilities for creating beautiful sequential animations
/// Perfect for medical lists, cards, and form elements
class StaggerAnimations {
  // ============ LIST STAGGER ANIMATIONS ============

  /// Creates a staggered list where items animate in sequence
  /// Perfect for medical records, profile lists, reminder cards
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = AppTheme.staggerDelay,
    Duration itemDuration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    StaggerDirection direction = StaggerDirection.bottomToTop,
    StaggerAnimationType animationType = StaggerAnimationType.fadeSlide,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = staggerDelay * index;

        return _buildStaggeredItem(
          child: child,
          delay: delay,
          duration: itemDuration,
          curve: curve,
          direction: direction,
          animationType: animationType,
        );
      }).toList(),
    );
  }

  /// Creates a staggered grid for cards, profile tiles, etc.
  static Widget staggeredGrid({
    required List<Widget> children,
    required int crossAxisCount,
    Duration staggerDelay = AppTheme.staggerDelay,
    Duration itemDuration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    StaggerDirection direction = StaggerDirection.bottomToTop,
    StaggerAnimationType animationType = StaggerAnimationType.fadeSlide,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
  }) {
    final rows = <Widget>[];

    for (int i = 0; i < children.length; i += crossAxisCount) {
      final rowChildren = <Widget>[];

      for (int j = 0; j < crossAxisCount && i + j < children.length; j++) {
        final childIndex = i + j;
        final delay = staggerDelay * childIndex;

        rowChildren.add(
          Expanded(
            child: _buildStaggeredItem(
              child: children[childIndex],
              delay: delay,
              duration: itemDuration,
              curve: curve,
              direction: direction,
              animationType: animationType,
            ),
          ),
        );
      }

      // Fill remaining spaces in incomplete rows
      while (rowChildren.length < crossAxisCount) {
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: mainAxisSpacing),
          child: Row(
            children: rowChildren
                .expand((child) => [child, SizedBox(width: crossAxisSpacing)])
                .take(rowChildren.length * 2 - 1)
                .toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  // ============ FORM STAGGER ANIMATIONS ============

  /// Staggered form fields for medical forms and profile creation
  static Widget staggeredForm({
    required List<Widget> formFields,
    Duration staggerDelay = AppTheme.staggerDelay,
    Duration itemDuration = AppTheme.standardDuration,
    double spacing = 16.0,
  }) {
    return Column(
      children: formFields.asMap().entries.map((entry) {
        final index = entry.key;
        final field = entry.value;
        final delay = staggerDelay * index;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < formFields.length - 1 ? spacing : 0,
          ),
          child: _buildStaggeredItem(
            child: field,
            delay: delay,
            duration: itemDuration,
            curve: AppTheme.easeOutCubic,
            direction: StaggerDirection.bottomToTop,
            animationType: StaggerAnimationType.fadeSlide,
          ),
        );
      }).toList(),
    );
  }

  // ============ DASHBOARD STAGGER ANIMATIONS ============

  /// Staggered dashboard widgets (stats, quick actions, activity feed)
  static Widget staggeredDashboard({
    required List<Widget> dashboardItems,
    Duration staggerDelay = AppTheme.staggerDelayLong,
    Duration itemDuration = AppTheme.standardDuration,
    double spacing = 20.0,
  }) {
    return Column(
      children: dashboardItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final delay = staggerDelay * index;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < dashboardItems.length - 1 ? spacing : 0,
          ),
          child: _buildStaggeredItem(
            child: item,
            delay: delay,
            duration: itemDuration,
            curve: AppTheme.easeOutCubic,
            direction: StaggerDirection.bottomToTop,
            animationType: StaggerAnimationType.fadeScale,
          ),
        );
      }).toList(),
    );
  }

  // ============ WAVE ANIMATIONS ============

  /// Creates a wave effect across children (great for button groups, tabs)
  static Widget wave({
    required List<Widget> children,
    Duration waveDuration = const Duration(milliseconds: 1500),
    Duration itemDuration = AppTheme.microDuration,
    WaveDirection direction = WaveDirection.leftToRight,
  }) {
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        // Calculate delay based on wave direction
        final delay = direction == WaveDirection.leftToRight
            ? Duration(
                milliseconds:
                    (waveDuration.inMilliseconds / children.length * index)
                        .round(),
              )
            : Duration(
                milliseconds:
                    (waveDuration.inMilliseconds /
                            children.length *
                            (children.length - 1 - index))
                        .round(),
              );

        return Expanded(
          child: _DelayedAnimation(
            delay: delay,
            child: CommonTransitions.scaleIn(
              duration: itemDuration,
              curve: AppTheme.bounceOut,
              child: child,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============ PRIVATE HELPER METHODS ============

  /// Builds individual staggered items
  static Widget _buildStaggeredItem({
    required Widget child,
    required Duration delay,
    required Duration duration,
    required Curve curve,
    required StaggerDirection direction,
    required StaggerAnimationType animationType,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: _buildAnimationByType(
        child: child,
        duration: duration,
        curve: curve,
        direction: direction,
        animationType: animationType,
      ),
    );
  }

  /// Builds animation based on type
  static Widget _buildAnimationByType({
    required Widget child,
    required Duration duration,
    required Curve curve,
    required StaggerDirection direction,
    required StaggerAnimationType animationType,
  }) {
    switch (animationType) {
      case StaggerAnimationType.fade:
        return CommonTransitions.fadeIn(
          duration: duration,
          curve: curve,
          child: child,
        );

      case StaggerAnimationType.scale:
        return CommonTransitions.scaleIn(
          duration: duration,
          curve: curve,
          child: child,
        );

      case StaggerAnimationType.slide:
        return CommonTransitions.slideInFromBottom(
          // Will be replaced with proper directional slide
          duration: duration,
          curve: curve,
          child: child,
        );

      case StaggerAnimationType.fadeSlide:
        final offset = _getSlideOffset(direction);
        return CommonTransitions.fadeSlideIn(
          duration: duration,
          curve: curve,
          direction: offset,
          child: child,
        );

      case StaggerAnimationType.fadeScale:
        return CommonTransitions.fadeScaleIn(
          duration: duration,
          curve: curve,
          child: child,
        );
    }
  }

  /// Gets slide offset based on direction
  static Offset _getSlideOffset(StaggerDirection direction) {
    switch (direction) {
      case StaggerDirection.topToBottom:
        return const Offset(0, -30);
      case StaggerDirection.bottomToTop:
        return const Offset(0, 30);
      case StaggerDirection.leftToRight:
        return const Offset(-30, 0);
      case StaggerDirection.rightToLeft:
        return const Offset(30, 0);
    }
  }
}

// ============ ENUMS ============

enum StaggerDirection { topToBottom, bottomToTop, leftToRight, rightToLeft }

enum StaggerAnimationType { fade, scale, slide, fadeSlide, fadeScale }

enum WaveDirection { leftToRight, rightToLeft }

// ============ HELPER WIDGETS ============

/// Widget that delays the display of its child
class _DelayedAnimation extends StatefulWidget {
  const _DelayedAnimation({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _show = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : const SizedBox.shrink();
  }
}
