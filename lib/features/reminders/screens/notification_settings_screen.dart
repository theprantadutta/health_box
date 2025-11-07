import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/notification_settings.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_loading.dart';
import '../services/notification_settings_service.dart';
import '../widgets/sound_picker_widget.dart';
import '../widgets/volume_slider_widget.dart';

/// Screen for configuring notification settings and sounds
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const NotificationSettingsScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late NotificationSettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _settingsService = NotificationSettingsService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.infoGradient,
            boxShadow: AppElevation.coloredShadow(
              HealthBoxDesignSystem.infoGradient.colors.first,
              opacity: 0.3,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'test',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Test Notifications'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Reset to Defaults'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sounds', icon: Icon(Icons.volume_up)),
            Tab(text: 'Vibration', icon: Icon(Icons.vibration)),
            Tab(text: 'Display', icon: Icon(Icons.visibility)),
            Tab(text: 'Advanced', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: FutureBuilder<NotificationSetting>(
        future: _settingsService.getNotificationSettings(
          profileId: widget.profileId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const HBLoading.circular();
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          final settings = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSoundsTab(settings),
              _buildVibrationTab(settings),
              _buildDisplayTab(settings),
              _buildAdvancedTab(settings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSoundsTab(NotificationSetting settings) {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSoundSection(
            'Medication Reminders',
            'Sound for medication reminders',
            settings.medicationSoundName,
            settings.medicationSoundVolume,
            (soundName, volume) => _updateMedicationSound(
              settings,
              soundName,
              volume,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          _buildSoundSection(
            'Appointments',
            'Sound for appointment reminders',
            settings.appointmentSoundName,
            settings.appointmentSoundVolume,
            (soundName, volume) => _updateAppointmentSound(
              settings,
              soundName,
              volume,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          _buildSoundSection(
            'General Reminders',
            'Sound for other reminders',
            settings.generalSoundName,
            settings.generalSoundVolume,
            (soundName, volume) => _updateGeneralSound(
              settings,
              soundName,
              volume,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationTab(NotificationSetting settings) {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vibration Settings',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  SwitchListTile(
                    title: const Text('Enable Vibration'),
                    subtitle: const Text('Vibrate when receiving notifications'),
                    value: settings.enableVibration,
                    onChanged: (value) => _updateVibrationSettings(
                      settings,
                      value,
                      null,
                    ),
                  ),
                  if (settings.enableVibration) ...[
                    SizedBox(height: AppSpacing.base),
                    Text(
                      'Vibration Pattern',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ...VibrationPatterns.allPatterns.map((pattern) {
                      if (pattern == VibrationPatterns.none) return const SizedBox.shrink();

                      return RadioListTile<String>(
                        title: Text(VibrationPatterns.getDisplayName(pattern)),
                        value: pattern,
                        groupValue: settings.vibrationPattern,
                        onChanged: (value) => _updateVibrationSettings(
                          settings,
                          settings.enableVibration,
                          value,
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => _testVibrationPattern(pattern),
                          tooltip: 'Test pattern',
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(NotificationSetting settings) {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Settings',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  SwitchListTile(
                    title: const Text('Show on Lock Screen'),
                    subtitle: const Text('Display notifications on lock screen'),
                    value: settings.showOnLockScreen,
                    onChanged: (value) => _updateDisplaySettings(
                      settings,
                      showOnLockScreen: value,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Show Medication Name'),
                    subtitle: const Text('Include medication name in notifications'),
                    value: settings.showMedicationName,
                    onChanged: (value) => _updateDisplaySettings(
                      settings,
                      showMedicationName: value,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Show Dosage'),
                    subtitle: const Text('Include dosage information'),
                    value: settings.showDosage,
                    onChanged: (value) => _updateDisplaySettings(
                      settings,
                      showDosage: value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base),
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LED Settings (Android)',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  SwitchListTile(
                    title: const Text('Enable LED'),
                    subtitle: const Text('Flash LED light for notifications'),
                    value: settings.enableLed,
                    onChanged: (value) => _updateLedSettings(settings, value),
                  ),
                  if (settings.enableLed) ...[
                    SizedBox(height: AppSpacing.base),
                    Text(
                      'LED Color',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildColorPicker(settings),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab(NotificationSetting settings) {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Persistent Notifications',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  SwitchListTile(
                    title: const Text('Enable Persistent Notifications'),
                    subtitle: const Text('Show persistent notifications for missed doses'),
                    value: settings.enablePersistentNotifications,
                    onChanged: (value) => _updatePersistentNotificationSettings(
                      settings,
                      value,
                    ),
                  ),
                  if (settings.enablePersistentNotifications) ...[
                    SizedBox(height: AppSpacing.base),
                    ListTile(
                      title: const Text('Timeout'),
                      subtitle: Text('${settings.persistentNotificationTimeout} minutes'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showTimeoutPicker(settings),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base),
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do Not Disturb',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  SwitchListTile(
                    title: const Text('Respect Do Not Disturb'),
                    subtitle: const Text('Honor system do not disturb settings'),
                    value: settings.respectDoNotDisturb,
                    onChanged: (value) => _updateDoNotDisturbSettings(
                      settings,
                      value,
                    ),
                  ),
                  ListTile(
                    title: const Text('Quiet Hours'),
                    subtitle: Text(_getQuietHoursText(settings)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showQuietHoursPicker(settings),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base),
          HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Snooze Settings',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                  ListTile(
                    title: const Text('Default Snooze Duration'),
                    subtitle: Text('${settings.defaultSnoozeMinutes} minutes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSnoozeDurationPicker(settings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSection(
    String title,
    String subtitle,
    String currentSound,
    double currentVolume,
    Function(String, double) onChanged,
  ) {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.base),
          SoundPickerWidget(
            currentSound: currentSound,
            onSoundChanged: (soundName) => onChanged(soundName, currentVolume),
          ),
          SizedBox(height: AppSpacing.base),
          VolumeSliderWidget(
            volume: currentVolume,
            onVolumeChanged: (volume) => onChanged(currentSound, volume),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(NotificationSetting settings) {
    final colors = [
      '#2196F3', // Blue
      '#4CAF50', // Green
      '#FF9800', // Orange
      '#F44336', // Red
      '#9C27B0', // Purple
      '#00BCD4', // Cyan
      '#FFC107', // Amber
      '#795548', // Brown
    ];

    return Wrap(
      spacing: 8,
      children: colors.map((colorHex) {
        final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
        final isSelected = settings.ledColor == colorHex;

        return GestureDetector(
          onTap: () => _updateLedColor(settings, colorHex),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? context.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXl * 1.5,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.base),
            Text(
              'Error loading settings',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.base),
            HBButton.primary(
              text: 'Retry',
              onPressed: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  // Update Methods

  Future<void> _updateMedicationSound(
    NotificationSetting settings,
    String soundName,
    double volume,
  ) async {
    try {
      await _settingsService.updateMedicationSound(
        profileId: widget.profileId,
        soundName: soundName,
        volume: volume,
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      _showErrorSnackBar('Failed to update medication sound: $e');
    }
  }

  Future<void> _updateAppointmentSound(
    NotificationSetting settings,
    String soundName,
    double volume,
  ) async {
    try {
      await _settingsService.updateAppointmentSound(
        profileId: widget.profileId,
        soundName: soundName,
        volume: volume,
      );
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update appointment sound: $e');
    }
  }

  Future<void> _updateGeneralSound(
    NotificationSetting settings,
    String soundName,
    double volume,
  ) async {
    try {
      await _settingsService.updateGeneralSound(
        profileId: widget.profileId,
        soundName: soundName,
        volume: volume,
      );
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update general sound: $e');
    }
  }

  Future<void> _updateVibrationSettings(
    NotificationSetting settings,
    bool enableVibration,
    String? vibrationPattern,
  ) async {
    try {
      await _settingsService.updateVibrationSettings(
        profileId: widget.profileId,
        enableVibration: enableVibration,
        vibrationPattern: vibrationPattern,
      );
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update vibration settings: $e');
    }
  }

  Future<void> _updateDisplaySettings(
    NotificationSetting settings, {
    bool? showOnLockScreen,
    bool? showMedicationName,
    bool? showDosage,
  }) async {
    try {
      // This would be implemented in the settings service
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update display settings: $e');
    }
  }

  Future<void> _updateLedSettings(
    NotificationSetting settings,
    bool enableLed,
  ) async {
    // Implementation for LED settings
    setState(() {});
  }

  Future<void> _updateLedColor(
    NotificationSetting settings,
    String color,
  ) async {
    // Implementation for LED color
    setState(() {});
  }

  Future<void> _updatePersistentNotificationSettings(
    NotificationSetting settings,
    bool enable,
  ) async {
    try {
      await _settingsService.updatePersistentNotificationSettings(
        profileId: widget.profileId,
        enablePersistentNotifications: enable,
      );
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update persistent notification settings: $e');
    }
  }

  Future<void> _updateDoNotDisturbSettings(
    NotificationSetting settings,
    bool respect,
  ) async {
    try {
      await _settingsService.updateDoNotDisturbSettings(
        profileId: widget.profileId,
        respectDoNotDisturb: respect,
      );
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to update do not disturb settings: $e');
    }
  }

  // Helper Methods

  String _getQuietHoursText(NotificationSetting settings) {
    if (settings.quietHoursStart == null || settings.quietHoursEnd == null) {
      return 'Not set';
    }
    return '${settings.quietHoursStart} - ${settings.quietHoursEnd}';
  }

  void _testVibrationPattern(String pattern) {
    // TODO: Implement vibration testing
  }

  void _showTimeoutPicker(NotificationSetting settings) {
    // TODO: Show timeout picker dialog
  }

  void _showQuietHoursPicker(NotificationSetting settings) {
    // TODO: Show quiet hours picker dialog
  }

  void _showSnoozeDurationPicker(NotificationSetting settings) {
    // TODO: Show snooze duration picker dialog
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'test':
        _testNotifications();
        break;
      case 'reset':
        _resetToDefaults();
        break;
    }
  }

  void _testNotifications() {
    // TODO: Implement notification testing
  }

  Future<void> _resetToDefaults() async {
    try {
      await _settingsService.resetToDefaults(profileId: widget.profileId);
      setState(() {});
      _showSuccessSnackBar('Settings reset to defaults');
    } catch (e) {
      _showErrorSnackBar('Failed to reset settings: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }
}