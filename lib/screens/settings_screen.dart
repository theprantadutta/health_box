import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/modern_card.dart';
import '../shared/theme/app_theme.dart';
import '../shared/animations/stagger_animations.dart';
import '../shared/providers/accessibility_providers.dart';
import '../shared/providers/onboarding_providers.dart';
import '../shared/providers/app_providers.dart';
import '../shared/providers/simple_profile_providers.dart';
import '../shared/providers/settings_providers.dart';
import '../shared/navigation/app_router.dart';
import '../data/database/app_database.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _deleteConfirmationController = TextEditingController();

  @override
  void dispose() {
    _deleteConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StaggerAnimations.staggeredList(
          children: [
            // User Profile Section
            _buildProfileSection(theme),
            const SizedBox(height: 16),

            // App Preferences
            _buildAppPreferencesSection(theme),
            const SizedBox(height: 16),

            // Accessibility Settings
            _buildAccessibilitySection(accessibilitySettings, theme),
            const SizedBox(height: 16),

            // Data Management
            _buildDataManagementSection(theme),
            const SizedBox(height: 16),

            // Privacy & Security
            _buildPrivacySection(theme),
            const SizedBox(height: 16),

            // Backup & Sync
            _buildBackupSyncSection(theme),
            const SizedBox(height: 16),

            // Support & About
            _buildSupportSection(theme),
            const SizedBox(height: 16),

            // Advanced Settings
            _buildAdvancedSection(theme),
          ],
          staggerDelay: AppTheme.microDuration,
          direction: StaggerDirection.bottomToTop,
          animationType: StaggerAnimationType.fadeSlide,
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return ModernCard(
      medicalTheme: MedicalCardTheme.primary,
      elevation: CardElevation.medium,
      enableHoverEffect: true,
      hoverElevation: CardElevation.high,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Consumer(
            builder: (context, ref, child) {
              final selectedProfileAsync = ref.watch(
                simpleSelectedProfileProvider,
              );

              return selectedProfileAsync.when(
                loading: () => _buildProfileCard(
                  context,
                  name: 'Health Box User',
                  subtitle: 'Loading profile...',
                  initials: 'HB',
                  trailing: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  onTap: null,
                ),
                error: (error, stack) => _buildProfileCard(
                  context,
                  name: 'Health Box User',
                  subtitle: 'Error loading profile',
                  initials: 'HB',
                  trailing: const Icon(Icons.error_outline, color: Colors.white70),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error loading profile data'),
                      ),
                    );
                  },
                ),
                data: (selectedProfile) {
                  final displayName = selectedProfile != null
                      ? '${selectedProfile.firstName} ${selectedProfile.lastName}'
                      : 'Health Box User';

                  final initials = selectedProfile != null
                      ? '${selectedProfile.firstName.isNotEmpty ? selectedProfile.firstName[0] : ''}${selectedProfile.lastName.isNotEmpty ? selectedProfile.lastName[0] : ''}'
                      : 'HB';

                  final age = selectedProfile != null
                      ? _calculateAge(selectedProfile.dateOfBirth)
                      : null;

                  final subtitle = selectedProfile != null
                      ? 'Age $age • ${selectedProfile.gender}${selectedProfile.bloodType != null ? ' • ${selectedProfile.bloodType}' : ''}'
                      : 'Tap to create your first profile';

                  return _buildProfileCard(
                    context,
                    name: displayName,
                    subtitle: subtitle,
                    initials: initials,
                    profile: selectedProfile,
                    onTap: () {
                      if (selectedProfile != null) {
                        context.push(
                          AppRoutes.profileForm,
                          extra: selectedProfile,
                        );
                      } else {
                        context.push(AppRoutes.profiles);
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String initials,
    FamilyMemberProfile? profile,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar with improved styling
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing widget or edit icon
                trailing ??
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Widget _buildAppPreferencesSection(ThemeData theme) {
    final themeMode = ref.watch(themeModeProvider);

    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'App Preferences',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Theme Settings
          ListTile(
            leading: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeText(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeSelector(),
          ),

          // Language Settings
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showLanguageSelection();
            },
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Receive reminders and alerts'),
            value: ref.watch(notificationsEnabledProvider),
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier).toggleNotifications(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifications enabled' : 'Notifications disabled',
                  ),
                ),
              );
            },
          ),

          // Reminders
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Reminders'),
            subtitle: const Text('Manage your medication and health reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.reminders),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(
    AccessibilitySettings accessibilitySettings,
    ThemeData theme,
  ) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.accessibility,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Accessibility',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // High Contrast Mode
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('High Contrast Mode'),
            subtitle: const Text(
              'Improve visibility with high contrast colors',
            ),
            value: accessibilitySettings.highContrast,
            onChanged: (value) {
              ref.read(highContrastModeProvider.notifier).state = value;
            },
          ),

          // Large Text Mode
          SwitchListTile(
            secondary: const Icon(Icons.format_size),
            title: const Text('Large Text'),
            subtitle: const Text('Increase text size for better readability'),
            value: accessibilitySettings.largeText,
            onChanged: (value) {
              ref.read(largeTextModeProvider.notifier).state = value;
            },
          ),

          // Reduced Animations
          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Reduce Animations'),
            subtitle: const Text('Minimize motion for better accessibility'),
            value: accessibilitySettings.reducedAnimations,
            onChanged: (value) {
              ref.read(reducedAnimationsModeProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Data Management',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Data'),
            subtitle: const Text('Export your medical data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.export),
          ),

          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import medical data from backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.import),
          ),

          ListTile(
            leading: const Icon(Icons.medical_information),
            title: const Text('Emergency Card'),
            subtitle: const Text('Manage emergency medical information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.emergencyCard),
          ),

          FutureBuilder<int>(
            future: AppDatabase.instance.getDatabaseSize(),
            builder: (context, snapshot) {
              final sizeText = snapshot.hasData
                  ? '${(snapshot.data! / 1024 / 1024).toStringAsFixed(2)} MB'
                  : 'Calculating...';

              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Database Size'),
                subtitle: Text('Current storage: $sizeText'),
                trailing: TextButton(
                  onPressed: _optimizeDatabase,
                  child: const Text('Optimize'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy & Security',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            secondary: const Icon(Icons.lock),
            title: const Text('Database Encryption'),
            subtitle: const Text('Your data is encrypted with SQLCipher'),
            value: true,
            onChanged: null, // Always encrypted
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View our privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(),
          ),

          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Terms of Service'),
            subtitle: const Text('View terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTermsOfService(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSyncSection(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Backup & Sync',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Google Drive Sync'),
            subtitle: const Text('Sync with Google Drive (Optional)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.sync),
          ),

          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Create Backup'),
            subtitle: const Text('Create a local backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _createBackup,
          ),

          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: const Text('Auto Backup'),
            subtitle: const Text('Automatically backup daily'),
            value: ref.watch(autoBackupEnabledProvider),
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier).toggleAutoBackup(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Auto backup enabled' : 'Auto backup disabled',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Support & About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text('Help Center'),
            subtitle: const Text('Get help and tutorials'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpCenter(),
          ),

          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _sendFeedback(),
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Health Box'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.engineering,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Advanced',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Debug Mode'),
            subtitle: const Text('Enable debug logging'),
            trailing: Switch(
              value: ref.watch(debugModeEnabledProvider),
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).toggleDebugMode(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Debug mode enabled' : 'Debug mode disabled',
                    ),
                  ),
                );
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset Onboarding'),
            subtitle: const Text('Show onboarding screens again'),
            onTap: _resetOnboarding,
          ),

          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Permanently delete all data'),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeSelector() {
    final currentTheme = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appNotifierProvider.notifier).setDarkMode(false);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appNotifierProvider.notifier).setDarkMode(true);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  // For system theme, we'll follow the system brightness
                  final brightness = MediaQuery.of(context).platformBrightness;
                  ref.read(appNotifierProvider.notifier).setDarkMode(brightness == Brightness.dark);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _optimizeDatabase() async {
    try {
      await AppDatabase.instance.vacuumDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database optimized successfully')),
        );
        setState(() {}); // Refresh database size
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to optimize database: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _createBackup() async {
    try {
      final backupPath = await AppDatabase.instance.backupDatabase();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup created: $backupPath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _resetOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Onboarding'),
        content: const Text(
          'This will show the onboarding screens again on next app launch. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(onboardingNotifierProvider.notifier)
                  .resetOnboarding();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Onboarding reset. Restart the app to see changes.',
                  ),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Data',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: const Text(
          'This will permanently delete ALL your medical data, profiles, and settings. This action cannot be undone.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmClearData();
            },
            child: Text(
              'Continue',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    _deleteConfirmationController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Final Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Type "DELETE ALL" to confirm permanent data deletion:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteConfirmationController,
                decoration: const InputDecoration(
                  hintText: 'DELETE ALL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _deleteConfirmationController.text == 'DELETE ALL'
                  ? () async {
                      Navigator.pop(context);
                      await _performDataClearing();
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('DELETE ALL DATA'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDataClearing() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Clearing all data...'),
            ],
          ),
        ),
      );

      // Clear database - we'll need to add this method to the database
      final database = ref.read(appDatabaseProvider);

      // Clear all tables
      await database.delete(database.familyMemberProfiles).go();
      await database.delete(database.medicalRecords).go();
      await database.delete(database.prescriptions).go();
      await database.delete(database.medications).go();
      await database.delete(database.labReports).go();
      await database.delete(database.vaccinations).go();
      await database.delete(database.allergies).go();
      await database.delete(database.chronicConditions).go();
      await database.delete(database.tags).go();
      await database.delete(database.attachments).go();
      await database.delete(database.reminders).go();
      await database.delete(database.emergencyCards).go();

      // Clear SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.clear();

      // Reset onboarding
      await ref.read(onboardingNotifierProvider.notifier).resetOnboarding();

      Navigator.pop(context); // Close loading dialog

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been permanently deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Health Box Privacy Policy\n\n'
            'Your privacy is important to us. Health Box stores all your medical data locally on your device with strong encryption.\n\n'
            'We do not collect, transmit, or store your personal health information on our servers.\n\n'
            'Optional Google Drive sync is encrypted and only accessible by you.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Health Box Terms of Service\n\n'
            'By using Health Box, you agree to use this app responsibly for managing your health information.\n\n'
            'This app is for informational purposes and should not replace professional medical advice.\n\n'
            'Always consult healthcare professionals for medical decisions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Help Center opening soon')));
  }

  void _showLanguageSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              trailing: const Icon(Icons.check),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Text('🇪🇸'),
              title: const Text('Español'),
              subtitle: const Text('Coming in future update'),
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              leading: const Text('🇫🇷'),
              title: const Text('Français'),
              subtitle: const Text('Coming in future update'),
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback! Please reach out to us through:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@healthbox.app'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email functionality requires url_launcher package')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Health Box',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 64),
      children: const [
        Text(
          'A secure, offline-first mobile application for managing your family\'s medical information.',
        ),
      ],
    );
  }
}
