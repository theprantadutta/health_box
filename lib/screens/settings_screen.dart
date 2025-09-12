import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/modern_card.dart';
import '../shared/theme/app_theme.dart';
import '../shared/providers/accessibility_providers.dart';
import '../shared/providers/onboarding_providers.dart';
import '../shared/providers/app_providers.dart';
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(isDarkMode),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Section
            _buildProfileSection(),
            const SizedBox(height: 16),
            
            // App Preferences
            _buildAppPreferencesSection(),
            const SizedBox(height: 16),
            
            // Accessibility Settings
            _buildAccessibilitySection(accessibilitySettings),
            const SizedBox(height: 16),
            
            // Data Management
            _buildDataManagementSection(),
            const SizedBox(height: 16),
            
            // Privacy & Security
            _buildPrivacySection(),
            const SizedBox(height: 16),
            
            // Backup & Sync
            _buildBackupSyncSection(),
            const SizedBox(height: 16),
            
            // Support & About
            _buildSupportSection(),
            const SizedBox(height: 16),
            
            // Advanced Settings
            _buildAdvancedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('Health Box User'),
            subtitle: const Text('Tap to edit profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile editing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile editing coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesSection() {
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
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'App Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language selection coming soon'),
                ),
              );
            },
          ),
          
          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Receive reminders and alerts'),
            value: true, // TODO: Connect to actual setting
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifications enabled' : 'Notifications disabled',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(AccessibilitySettings accessibilitySettings) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.accessibility,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Accessibility',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // High Contrast Mode
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Improve visibility with high contrast colors'),
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

  Widget _buildDataManagementSection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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

  Widget _buildPrivacySection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy & Security',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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

  Widget _buildBackupSyncSection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Backup & Sync',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
            value: false, // TODO: Connect to actual setting
            onChanged: (value) {
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

  Widget _buildSupportSection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Support & About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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

  Widget _buildAdvancedSection() {
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.engineering,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Advanced',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              value: false, // TODO: Connect to actual setting
              onChanged: (value) {
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
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
                  // TODO: Fix theme provider to be StateNotifier
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme change coming soon')),
                  );
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
                  // TODO: Fix theme provider to be StateNotifier
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme change coming soon')),
                  );
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
                  // TODO: Fix theme provider to be StateNotifier
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme change coming soon')),
                  );
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
          const SnackBar(
            content: Text('Database optimized successfully'),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created: $backupPath'),
          ),
        );
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
              await ref.read(onboardingNotifierProvider.notifier).resetOnboarding();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Onboarding reset. Restart the app to see changes.'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Type "DELETE ALL" to confirm permanent data deletion:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // TODO: Implement actual data clearing with text confirmation
        ],
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help Center opening soon'),
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback form coming soon'),
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