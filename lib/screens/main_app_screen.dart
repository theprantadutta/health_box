import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

import '../shared/navigation/app_router.dart';
import '../shared/utils/responsive_utils.dart';
import '../shared/utils/accessibility_utils.dart';
import '../shared/navigation/advanced_salomon_bottom_bar.dart';

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
  const MainAppScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.settings,
      ),
    ];

    final railDestinations = destinations
        .map(
          (dest) => NavigationRailDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
          ),
        )
        .toList();

    if (ResponsiveUtils.shouldShowRail(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: ResponsiveUtils.isDesktop(context),
              destinations: railDestinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, ref, index),
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
      bottomNavigationBar: AdvancedSalomonBottomBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onDestinationSelected(context, ref, index),
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedColorOpacity: 0.15,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        items: [
          AdvancedSalomonBottomBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            title: Text(l10n.dashboard),
            selectedColor: theme.colorScheme.primary,
          ),
          AdvancedSalomonBottomBarItem(
            icon: const Icon(Icons.people_outlined),
            activeIcon: const Icon(Icons.people),
            title: Text(l10n.profiles),
            selectedColor: theme.colorScheme.secondary,
          ),
          AdvancedSalomonBottomBarItem(
            icon: const Icon(Icons.medical_information_outlined),
            activeIcon: const Icon(Icons.medical_information),
            title: const Text('Records'),
            selectedColor: theme.colorScheme.tertiary,
          ),
          AdvancedSalomonBottomBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            title: Text(l10n.settings),
            selectedColor: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    ref.read(selectedIndexProvider.notifier).setIndex(index);

    final routes = [
      AppRoutes.dashboard,
      AppRoutes.profiles,
      AppRoutes.medicalRecords,
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
  const ProfileDetailScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Details')),
      body: Center(child: Text('Profile ID: $profileId')),
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
      body: const Center(child: Text('Reminders List - Coming Soon')),
    );
  }
}

class ReminderFormScreen extends ConsumerWidget {
  const ReminderFormScreen({super.key, this.reminderId});

  final String? reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = reminderId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Reminder' : 'Add Reminder')),
      body: const Center(child: Text('Reminder Form - Coming Soon')),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
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
