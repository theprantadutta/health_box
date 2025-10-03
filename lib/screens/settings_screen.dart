import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/modern_card.dart';
import '../shared/theme/app_theme.dart';
import '../shared/theme/design_system.dart';
import '../shared/animations/stagger_animations.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.medicalOrange,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.medicalOrange.colors.first
                    .withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
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
                  trailing: const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                  ),
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
              Icon(Icons.settings, color: theme.colorScheme.primary),
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
              ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleNotifications(value);
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
              Icon(Icons.security, color: theme.colorScheme.primary),
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

          ListTile(
            leading: Icon(
              Icons.verified_user,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Database Security'),
            subtitle: const Text('Your data is secured with SQLCipher encryption'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Secure',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View our comprehensive privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
          ),

          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Terms of Service'),
            subtitle: const Text('View terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/terms-of-service'),
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
              Icon(Icons.cloud_sync, color: theme.colorScheme.primary),
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
              ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleAutoBackup(value);
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
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (Set<ThemeMode> selection) {
                final value = selection.first;
                if (value == ThemeMode.light) {
                  ref.read(appNotifierProvider.notifier).setDarkMode(false);
                } else if (value == ThemeMode.dark) {
                  ref.read(appNotifierProvider.notifier).setDarkMode(true);
                } else if (value == ThemeMode.system) {
                  // For system theme, we'll follow the system brightness
                  final brightness = MediaQuery.of(context).platformBrightness;
                  ref
                      .read(appNotifierProvider.notifier)
                      .setDarkMode(brightness == Brightness.dark);
                }
                context.pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
              onTap: () => context.pop(),
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
            onPressed: () => context.pop(),
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
            const Text(
              'We value your feedback! Please reach out to us through:',
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@healthbox.app'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Email functionality requires url_launcher package',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
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
