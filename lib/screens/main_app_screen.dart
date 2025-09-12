import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

import '../shared/navigation/app_router.dart';
import '../shared/utils/responsive_utils.dart';
import '../shared/utils/accessibility_utils.dart';

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
    
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
      ),
      NavigationDestination(
        icon: const Icon(Icons.people_outlined),
        selectedIcon: const Icon(Icons.people),
        label: l10n.profiles,
      ),
      NavigationDestination(
        icon: const Icon(Icons.medical_information_outlined),
        selectedIcon: const Icon(Icons.medical_information),
        label: l10n.medicalRecords,
      ),
      NavigationDestination(
        icon: const Icon(Icons.notifications_outlined),
        selectedIcon: const Icon(Icons.notifications),
        label: l10n.reminders,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.settings,
      ),
    ];

    final railDestinations = destinations
        .map((dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: Text(dest.label),
            ))
        .toList();

    if (ResponsiveUtils.shouldShowRail(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: ResponsiveUtils.isDesktop(context),
              destinations: railDestinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onDestinationSelected(
                context,
                ref,
                index,
              ),
              labelType: ResponsiveUtils.getNavigationRailLabelType(context),
              minWidth: ResponsiveUtils.getNavigationRailWidth(context),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 1,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(
          context,
          ref,
          index,
        ),
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: Semantics(
              label: dest.label,
              hint: AccessibilityUtils.getCommonHint('navigate'),
              excludeSemantics: false,
              child: dest.icon,
            ),
            selectedIcon: Semantics(
              label: '${dest.label} selected',
              hint: 'Currently selected tab',
              excludeSemantics: false,
              child: dest.selectedIcon ?? dest.icon,
            ),
            label: dest.label,
          );
        }).toList(),
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