import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

import '../shared/navigation/app_router.dart';
import '../shared/utils/responsive_utils.dart';
import '../shared/utils/accessibility_utils.dart';
// import '../shared/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: ResponsiveUtils.buildResponsiveSafeArea(
        context: context,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  
                  if (AccessibilityUtils.isScreenReaderActive(context)) {
                    AccessibilityUtils.announceToScreenReader(
                      'Page ${page + 1} of 3',
                    );
                  }
                },
                children: [
                  _buildWelcomePage(context, l10n),
                  _buildFeaturesPage(context, l10n),
                  _buildPrivacyPage(context, l10n),
                ],
              ),
            ),
            _buildBottomNavigation(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    
    return ResponsiveUtils.buildResponsiveContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: 'Health Box logo',
            child: Icon(
              Icons.medical_information,
              size: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 120,
              ),
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            header: true,
            child: Text(
              l10n?.welcome ?? 'Welcome to Health Box',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 28,
                ),
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.onboardingDescription ?? 'Secure medical data management',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 16,
              ),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    
    final features = [
      {
        'icon': Icons.offline_bolt,
        'title': 'Offline First',
        'description': 'All your data is stored locally on your device. No internet required for core functionality.',
      },
      {
        'icon': Icons.security,
        'title': 'Encrypted Storage',
        'description': 'Your medical data is protected with SQLCipher encryption at rest.',
      },
      {
        'icon': Icons.family_restroom,
        'title': 'Family Profiles',
        'description': 'Manage medical records for your entire family in one secure app.',
      },
      {
        'icon': Icons.notification_important,
        'title': 'Smart Reminders',
        'description': 'Never miss medication doses or important medical appointments.',
      },
    ];

    return ResponsiveUtils.buildResponsiveContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Key Features',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 28,
                ),
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ...features.map((feature) => _buildFeatureItem(
                context,
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['description'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibilityUtils.buildSemanticIcon(
            icon: icon,
            semanticLabel: '$title icon',
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    
    return ResponsiveUtils.buildResponsiveContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: 'Privacy shield icon',
            child: Icon(
              Icons.privacy_tip,
              size: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 120,
              ),
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            header: true,
            child: Text(
              'Privacy First',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 28,
                ),
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your medical data never leaves your device unless you choose to sync it. '
            'Optional Google Drive sync uses end-to-end encryption to protect your privacy.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 16,
              ),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No central servers',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Local encryption with SQLCipher',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Optional encrypted cloud backup',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == 2;
    
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => AccessibilityUtils.excludeFromSemantics(
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                )
              else
                const SizedBox.shrink(),
              
              FilledButton(
                onPressed: () {
                  if (isLastPage) {
                    _completeOnboarding(context);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(isLastPage ? (l10n?.getStarted ?? 'Get Started') : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    try {
      // TODO: Implement shared preferences provider
      // await ref.read(sharedPreferencesProvider).setBool('onboarding_complete', true);
      
      if (mounted) {
        context.pushReplacement(AppRoutes.dashboard);
        
        if (AccessibilityUtils.isScreenReaderActive(context)) {
          AccessibilityUtils.announceToScreenReader(
            'Onboarding completed. Welcome to Health Box!',
          );
        }
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        context.pushReplacement(AppRoutes.dashboard);
      }
    }
  }
}