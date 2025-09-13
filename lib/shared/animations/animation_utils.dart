import 'package:flutter/material.dart';
import 'staggered_animations.dart';
import 'parallax_scroll.dart';
import 'hero_animations.dart';
import 'page_transitions.dart';

// Animation Utility Class with Static Helper Methods
class AnimationUtils {
  AnimationUtils._();
  
  // Staggered List Animation Helpers
  static Widget createStaggeredList({
    required List<Widget> children,
    StaggeredAnimationType type = StaggeredAnimationType.combined,
    Duration duration = const Duration(milliseconds: 800),
    Duration staggerDelay = const Duration(milliseconds: 100),
    String? healthContext,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return StaggeredListView(
      children: children,
      animationType: type,
      animationDuration: duration,
      staggerDelay: staggerDelay,
      healthContext: healthContext,
      padding: padding,
      physics: physics,
    );
  }
  
  static Widget createStaggeredGrid({
    required List<Widget> children,
    int crossAxisCount = 2,
    Duration duration = const Duration(milliseconds: 1000),
    Duration staggerDelay = const Duration(milliseconds: 150),
    String? healthContext,
    EdgeInsetsGeometry? padding,
  }) {
    return HealthStaggeredGrid(
      children: children,
      crossAxisCount: crossAxisCount,
      animationDuration: duration,
      staggerDelay: staggerDelay,
      healthContext: healthContext,
      padding: padding,
    );
  }
  
  // Parallax Animation Helpers
  static Widget createParallaxScroll({
    required Widget child,
    required List<Widget> backgroundLayers,
    List<double>? parallaxFactors,
    String? healthContext,
    ScrollController? controller,
  }) {
    final factors = parallaxFactors ?? 
        List.generate(backgroundLayers.length, (i) => (i + 1) * 0.3);
    
    final layers = List.generate(backgroundLayers.length, (i) {
      return ParallaxLayer(
        child: backgroundLayers[i],
        parallaxFactor: factors[i],
        opacity: 0.8 - (i * 0.2),
      );
    });
    
    return PremiumParallaxScroll(
      layers: layers,
      child: child,
      healthContext: healthContext,
      controller: controller,
    );
  }
  
  static Widget createScrollReveal({
    required Widget child,
    RevealDirection direction = RevealDirection.up,
    Duration duration = const Duration(milliseconds: 600),
    bool enableHealthGlow = false,
    String? healthContext,
  }) {
    return ScrollRevealWidget(
      child: child,
      direction: direction,
      animationDuration: duration,
      enableHealthGlow: enableHealthGlow,
      healthContext: healthContext,
    );
  }
  
  // Hero Animation Helpers
  static Widget createHealthHero({
    required String tag,
    required Widget child,
    String? healthContext,
    bool enableGlow = true,
    bool enableScale = true,
  }) {
    return PremiumHero(
      tag: tag,
      child: child,
      healthContext: healthContext,
      enableGlow: enableGlow,
      enableScale: enableScale,
    );
  }
  
  static Widget createProfileHero({
    required String profileId,
    required String profileName,
    String? profileImage,
    String healthStatus = 'good',
    double size = 60.0,
    VoidCallback? onTap,
  }) {
    return ProfileAvatarHero(
      heroTag: HeroAnimationUtils.profileHeroTag(profileId),
      profileName: profileName,
      profileImage: profileImage,
      healthStatus: healthStatus,
      size: size,
      onTap: onTap,
    );
  }
  
  static Widget createHealthFAB({
    required String context,
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return HealthFABHero(
      heroTag: HeroAnimationUtils.fabHeroTag(context),
      icon: icon,
      healthContext: context,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
  
  // Page Transition Helpers
  static Page<T> createHealthTransition<T>({
    required Widget child,
    PageTransitionType type = PageTransitionType.healthSlide,
    String? healthContext,
    Duration? duration,
    LocalKey? key,
    String? name,
  }) {
    return buildPremiumPage<T>(
      child: child,
      transitionType: type,
      healthContext: healthContext,
      duration: duration ?? const Duration(milliseconds: 400),
      key: key,
      name: name,
    );
  }
  
  // Combined Animation Presets
  static Widget createHealthDashboard({
    required List<Widget> cardChildren,
    Widget? parallaxBackground,
    String healthContext = 'wellness',
    ScrollController? scrollController,
  }) {
    final staggeredCards = createStaggeredGrid(
      children: cardChildren,
      healthContext: healthContext,
      duration: const Duration(milliseconds: 1200),
      staggerDelay: const Duration(milliseconds: 200),
    );
    
    if (parallaxBackground != null) {
      return createParallaxScroll(
        child: staggeredCards,
        backgroundLayers: [parallaxBackground],
        parallaxFactors: [0.5],
        healthContext: healthContext,
        controller: scrollController,
      );
    }
    
    return staggeredCards;
  }
  
  static Widget createHealthList({
    required List<Widget> items,
    String? healthContext,
    bool enableParallax = false,
    Widget? parallaxBackground,
    ScrollController? scrollController,
  }) {
    final staggeredList = createStaggeredList(
      children: items.map((item) => 
        createScrollReveal(
          child: item,
          enableHealthGlow: healthContext != null,
          healthContext: healthContext,
        )
      ).toList(),
      type: StaggeredAnimationType.combined,
      healthContext: healthContext,
    );
    
    if (enableParallax && parallaxBackground != null) {
      return createParallaxScroll(
        child: staggeredList,
        backgroundLayers: [parallaxBackground],
        healthContext: healthContext,
        controller: scrollController,
      );
    }
    
    return staggeredList;
  }
  
  // Health Context Animation Combinations
  static Widget createMedicationScreen({
    required List<Widget> medicationCards,
    ScrollController? scrollController,
  }) {
    return createHealthDashboard(
      cardChildren: medicationCards,
      parallaxBackground: const HealthParallaxBackground(
        healthContext: 'medication',
        opacity: 0.08,
      ),
      healthContext: 'medication',
      scrollController: scrollController,
    );
  }
  
  static Widget createNutritionScreen({
    required List<Widget> nutritionItems,
    ScrollController? scrollController,
  }) {
    return createHealthList(
      items: nutritionItems,
      healthContext: 'nutrition',
      enableParallax: true,
      parallaxBackground: const HealthParallaxBackground(
        healthContext: 'nutrition',
        opacity: 0.06,
      ),
      scrollController: scrollController,
    );
  }
  
  static Widget createFitnessScreen({
    required List<Widget> fitnessCards,
    ScrollController? scrollController,
  }) {
    return createHealthDashboard(
      cardChildren: fitnessCards,
      parallaxBackground: const HealthParallaxBackground(
        healthContext: 'fitness',
        opacity: 0.1,
      ),
      healthContext: 'fitness',
      scrollController: scrollController,
    );
  }
  
  static Widget createHeartHealthScreen({
    required List<Widget> heartItems,
    ScrollController? scrollController,
  }) {
    return createHealthList(
      items: heartItems,
      healthContext: 'heart',
      enableParallax: true,
      parallaxBackground: const HealthParallaxBackground(
        healthContext: 'heart',
        opacity: 0.07,
      ),
      scrollController: scrollController,
    );
  }
  
  // Floating Action Button with Scroll Awareness
  static Widget createScrollAwareFAB({
    required VoidCallback onPressed,
    required IconData icon,
    String? healthContext,
    String? tooltip,
    double scrollThreshold = 100.0,
  }) {
    return ScrollAwareFAB(
      onPressed: onPressed,
      icon: icon,
      healthContext: healthContext,
      tooltip: tooltip,
      scrollThreshold: scrollThreshold,
    );
  }
}

// Animation Timing Constants
class AnimationTiming {
  AnimationTiming._();
  
  // Standard Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
  static const Duration slowest = Duration(milliseconds: 1200);
  
  // Health-specific Durations
  static const Duration heartbeat = Duration(milliseconds: 100);
  static const Duration breathing = Duration(milliseconds: 4000);
  static const Duration pillFloat = Duration(milliseconds: 3000);
  static const Duration leafGrow = Duration(milliseconds: 2500);
  static const Duration waveFlow = Duration(milliseconds: 6000);
  
  // Stagger Delays
  static const Duration shortStagger = Duration(milliseconds: 50);
  static const Duration normalStagger = Duration(milliseconds: 100);
  static const Duration longStagger = Duration(milliseconds: 150);
  static const Duration extraLongStagger = Duration(milliseconds: 200);
}

// Animation Curves for Health App
class HealthCurves {
  HealthCurves._();
  
  // Standard curves
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve snap = Curves.easeOutBack;
  
  // Health-specific curves
  static const Curve heartbeat = Curves.easeInOutSine;
  static const Curve breathing = Curves.easeInOut;
  static const Curve pillBounce = Curves.bounceOut;
  static const Curve leafSway = Curves.easeInOutSine;
  static const Curve energyFlow = Curves.linear;
}

// Mixin for Widgets that need Animation Management
mixin AnimationManager<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<double>> _animations = {};
  
  AnimationController createController({
    required String name,
    required Duration duration,
  }) {
    final controller = AnimationController(duration: duration, vsync: this);
    _controllers[name] = controller;
    return controller;
  }
  
  Animation<double> createAnimation({
    required String name,
    required String controllerName,
    required Tween<double> tween,
    Curve curve = Curves.linear,
  }) {
    final controller = _controllers[controllerName];
    if (controller == null) {
      throw ArgumentError('Controller $controllerName not found');
    }
    
    final animation = tween.animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
    _animations[name] = animation;
    return animation;
  }
  
  AnimationController? getController(String name) => _controllers[name];
  Animation<double>? getAnimation(String name) => _animations[name];
  
  void startAnimation(String name) => _controllers[name]?.forward();
  void reverseAnimation(String name) => _controllers[name]?.reverse();
  void resetAnimation(String name) => _controllers[name]?.reset();
  
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

// Extension for Easy Animation Access
extension AnimationExtensions on Widget {
  Widget withStaggeredAnimation({
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: this,
    );
  }
  
  Widget withHealthGlow({
    required String healthContext,
    double intensity = 0.2,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final contextColor = _getHealthColor(healthContext, theme);
        
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: contextColor.withValues(alpha: intensity),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: this,
        );
      },
    );
  }
  
  static Color _getHealthColor(String context, ThemeData theme) {
    switch (context.toLowerCase()) {
      case 'medication':
        return const Color(0xFFFFC107);
      case 'heart':
        return const Color(0xFFE91E63);
      case 'wellness':
        return const Color(0xFF9C27B0);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'fitness':
        return const Color(0xFF03A9F4);
      default:
        return theme.colorScheme.primary;
    }
  }
}