import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

import '../shared/navigation/app_router.dart';
import '../shared/utils/responsive_utils.dart';
import '../shared/utils/accessibility_utils.dart';
import '../shared/widgets/premium_navigation.dart';
import '../shared/theme/app_theme.dart';

class SelectedIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void setIndex(int index) {
    state = index;
  }
}

final selectedIndexProvider = NotifierProvider<SelectedIndexNotifier, int>(() {
  return SelectedIndexNotifier();
});

class MainAppScreen extends ConsumerWidget {
  const MainAppScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    
    final premiumDestinations = [
      PremiumNavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
        healthContext: 'wellness',
        tooltip: l10n.dashboard,
      ),
      PremiumNavigationDestination(
        icon: const Icon(Icons.people_outlined),
        selectedIcon: const Icon(Icons.people),
        label: l10n.profiles,
        healthContext: 'heart',
        tooltip: l10n.profiles,
      ),
      PremiumNavigationDestination(
        icon: const Icon(Icons.medical_information_outlined),
        selectedIcon: const Icon(Icons.medical_information),
        label: l10n.medicalRecords,
        healthContext: 'medication',
        tooltip: l10n.medicalRecords,
      ),
      PremiumNavigationDestination(
        icon: const Icon(Icons.notifications_outlined),
        selectedIcon: const Icon(Icons.notifications),
        label: l10n.reminders,
        healthContext: 'fitness',
        tooltip: l10n.reminders,
      ),
      PremiumNavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.settings,
        healthContext: 'nutrition',
        tooltip: l10n.settings,
      ),
    ];

    // Legacy destinations for compatibility (if needed later)
    // final destinations = premiumDestinations.map((dest) => NavigationDestination(
    //   icon: dest.icon,
    //   selectedIcon: dest.selectedIcon,
    //   label: dest.label,
    // )).toList();

    if (ResponsiveUtils.shouldShowRail(context)) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Row(
          children: [
            // Premium Navigation Rail
            PremiumNavigationRail(
              destinations: premiumDestinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onDestinationSelected(
                context,
                ref,
                index,
              ),
              extended: ResponsiveUtils.isDesktop(context),
              width: ResponsiveUtils.getNavigationRailWidth(context),
              extendedWidth: 280.0,
              elevation: 2.0,
              enableGlow: true,
              healthContext: _getCurrentHealthContext(selectedIndex),
              margin: const EdgeInsets.all(8.0),
            ),
            
            // Content area with enhanced styling
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: AppTheme.getCardShadow(
                    Theme.of(context).brightness == Brightness.dark
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        margin: const EdgeInsets.only(bottom: 100.0), // Space for floating nav
        child: child,
      ),
      bottomNavigationBar: null, // We'll use our floating nav instead
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: PremiumNavigationBar(
          destinations: premiumDestinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onDestinationSelected(
            context,
            ref,
            index,
          ),
          enableGlow: true,
          enableFloating: true,
          enableMorphing: true,
          healthContext: _getCurrentHealthContext(selectedIndex),
          height: 72.0,
          elevation: 12.0,
          enableHapticFeedback: true,
        ),
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    ref.read(selectedIndexProvider.notifier).setIndex(index);
    
    final routes = [
      AppRoutes.dashboard,
      AppRoutes.profiles,
      AppRoutes.medicalRecords,
      AppRoutes.reminders,
      AppRoutes.settings,
    ];

    if (index < routes.length) {
      context.go(routes[index]);
      
      final l10n = AppLocalizations.of(context)!;
      final labels = [
        l10n.dashboard,
        l10n.profiles,
        l10n.medicalRecords,
        l10n.reminders,
        l10n.settings,
      ];
      
      if (AccessibilityUtils.isScreenReaderActive(context)) {
        AccessibilityUtils.announceToScreenReader(
          'Navigated to ${labels[index]}',
        );
      }
    }
  }
  
  String _getCurrentHealthContext(int index) {
    const contexts = ['wellness', 'heart', 'medication', 'fitness', 'nutrition'];
    return index < contexts.length ? contexts[index] : 'wellness';
  }
}

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({
    super.key,
    required this.profileId,
  });

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
      ),
      body: Center(
        child: Text('Profile ID: $profileId'),
      ),
    );
  }
}

class ReminderListScreen extends ConsumerWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
        actions: [
          IconButton(
            onPressed: () => context.push('${AppRoutes.reminders}/form'),
            icon: const Icon(Icons.add),
            tooltip: l10n.add,
          ),
        ],
      ),
      body: const Center(
        child: Text('Reminders List - Coming Soon'),
      ),
    );
  }
}

class ReminderFormScreen extends ConsumerWidget {
  const ReminderFormScreen({
    super.key,
    this.reminderId,
  });

  final String? reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = reminderId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: const Center(
        child: Text('Reminder Form - Coming Soon'),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        children: [
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(l10n.export),
            subtitle: const Text('Export your data'),
            onTap: () => context.push('${AppRoutes.settings}/export'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text(l10n.import),
            subtitle: const Text('Import your data'),
            onTap: () => context.push('${AppRoutes.settings}/import'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: Text(l10n.emergencyCard),
            subtitle: const Text('Generate emergency medical card'),
            onTap: () => context.push('${AppRoutes.settings}/emergency-card'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l10n.sync),
            subtitle: const Text('Sync settings'),
            onTap: () => context.push('${AppRoutes.settings}/sync'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}