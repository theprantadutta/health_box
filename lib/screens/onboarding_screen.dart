import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

import '../shared/navigation/app_router.dart';
import '../shared/utils/responsive_utils.dart';
import '../shared/utils/accessibility_utils.dart';
import '../shared/providers/onboarding_providers.dart';
import '../shared/providers/backup_preference_providers.dart';
import '../features/sync/providers/google_drive_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  BackupStrategy _selectedBackupStrategy = BackupStrategy.localOnly;
  bool _isSettingUpBackup = false;

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
                      'Page ${page + 1} of 4',
                    );
                  }
                },
                children: [
                  _buildWelcomePage(context, l10n),
                  _buildFeaturesPage(context, l10n),
                  _buildPrivacyPage(context, l10n),
                  _buildBackupStrategyPage(context, l10n),
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
        'description':
            'All your data is stored locally on your device. No internet required for core functionality.',
      },
      {
        'icon': Icons.security,
        'title': 'Encrypted Storage',
        'description':
            'Your medical data is protected with SQLCipher encryption at rest.',
      },
      {
        'icon': Icons.family_restroom,
        'title': 'Family Profiles',
        'description':
            'Manage medical records for your entire family in one secure app.',
      },
      {
        'icon': Icons.notification_important,
        'title': 'Smart Reminders',
        'description':
            'Never miss medication doses or important medical appointments.',
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
          ...features.map(
            (feature) => _buildFeatureItem(
              context,
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
            ),
          ),
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

  Widget _buildBackupStrategyPage(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);

    return ResponsiveUtils.buildResponsiveContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: 'Backup strategy icon',
            child: Icon(
              Icons.cloud_sync,
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
              'Backup Strategy',
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
            'Choose how you want to backup your medical data. You can change this later in settings.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 16,
              ),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildBackupOption(
            context,
            icon: Icons.phone_android,
            title: 'Local Only',
            description: 'Keep all data on your device only. No cloud backup.',
            isSelected: _selectedBackupStrategy == BackupStrategy.localOnly,
            onTap: () {
              setState(() {
                _selectedBackupStrategy = BackupStrategy.localOnly;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildBackupOption(
            context,
            icon: Icons.cloud,
            title: 'Google Drive Backup',
            description: 'Encrypted backup to your Google Drive for additional security.',
            isSelected: _selectedBackupStrategy == BackupStrategy.googleDrive,
            onTap: () {
              setState(() {
                _selectedBackupStrategy = BackupStrategy.googleDrive;
              });
            },
          ),
          if (_isSettingUpBackup) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'Setting up backup...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
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
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == 3;

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => AccessibilityUtils.excludeFromSemantics(
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
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
                onPressed: _isSettingUpBackup
                    ? null
                    : () {
                        if (isLastPage) {
                          _completeOnboarding(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                child: _isSettingUpBackup
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isLastPage ? (l10n?.getStarted ?? 'Get Started') : 'Next',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    if (_isSettingUpBackup) return;

    setState(() {
      _isSettingUpBackup = true;
    });

    try {
      // Save backup preference
      await ref.read(backupPreferenceNotifierProvider.notifier).setBackupPreference(
        enabled: _selectedBackupStrategy != BackupStrategy.localOnly,
        strategy: _selectedBackupStrategy,
      );

      // If Google Drive backup is selected, attempt to sign in
      if (_selectedBackupStrategy == BackupStrategy.googleDrive) {
        final authSuccess = await ref.read(googleDriveAuthProvider.notifier).signIn();
        if (!authSuccess) {
          // If authentication fails, show error and revert to local only
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Drive setup failed. Continuing with local-only backup.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Set to local only backup
          await ref.read(backupPreferenceNotifierProvider.notifier).setBackupPreference(
            enabled: false,
            strategy: BackupStrategy.localOnly,
          );
        }
      }

      if (mounted) {
        // Mark onboarding as completed
        await ref
            .read(onboardingNotifierProvider.notifier)
            .completeOnboarding();

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
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup error: $e. Continuing with local backup.'),
            backgroundColor: Colors.red,
          ),
        );

        // Revert to local only and complete onboarding
        await ref.read(backupPreferenceNotifierProvider.notifier).setBackupPreference(
          enabled: false,
          strategy: BackupStrategy.localOnly,
        );

        await ref
            .read(onboardingNotifierProvider.notifier)
            .completeOnboarding();
        context.pushReplacement(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSettingUpBackup = false;
        });
      }
    }
  }
}
