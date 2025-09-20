import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';

import '../../screens/main_app_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/settings_screen.dart' as settings;
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profiles/screens/profile_list_screen.dart';
import '../../features/profiles/screens/profile_form_screen.dart';
import '../../features/medical_records/screens/medical_record_list_screen.dart';
import '../../features/medical_records/screens/medical_record_detail_screen.dart';
import '../../features/medical_records/screens/prescription_form_screen.dart';
import '../../features/medical_records/screens/medication_form_screen.dart';
import '../../features/medical_records/screens/lab_report_form_screen.dart';
import '../../features/export/screens/export_screen.dart';
import '../../features/export/screens/import_screen.dart';
import '../../features/export/screens/emergency_card_screen.dart';
import '../../features/sync/screens/sync_settings_screen.dart';
import '../../features/analytics/screens/vitals_tracking_screen.dart';
import '../../features/ocr/screens/ocr_scan_screen.dart';
import '../../features/ocr/services/ocr_service.dart';
import '../../features/reminders/screens/reminders_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String profiles = '/profiles';
  static const String profileForm = '/profiles/form';
  static const String medicalRecords = '/medical-records';
  static const String medicalRecordDetail = '/medical-records/detail';
  static const String prescriptionForm = '/medical-records/prescription/form';
  static const String medicationForm = '/medical-records/medication/form';
  static const String labReportForm = '/medical-records/lab-report/form';
  static const String reminders = '/reminders';
  static const String settings = '/settings';
  static const String export = '/settings/export';
  static const String import = '/settings/import';
  static const String emergencyCard = '/settings/emergency-card';
  static const String sync = '/settings/sync';
  static const String vitalsTracking = '/analytics/vitals';
  static const String ocrScan = '/ocr/scan';
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title - Coming Soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app with bottom navigation (only for main tabs)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainAppScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),

          GoRoute(
            path: AppRoutes.profiles,
            name: 'profiles',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileListScreen()),
          ),

          GoRoute(
            path: AppRoutes.medicalRecords,
            name: 'medical-records',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MedicalRecordListScreen()),
          ),

          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: settings.SettingsScreen()),
          ),
        ],
      ),

      // Full screen overlays (no bottom navigation)
      GoRoute(
        path: '${AppRoutes.profiles}/form',
        name: 'profile-form',
        builder: (context, state) {
          final profile = state.extra as FamilyMemberProfile?;
          return ProfileFormScreen(profile: profile);
        },
      ),

      GoRoute(
        path: '${AppRoutes.medicalRecords}/detail/:recordId',
        name: 'medical-record-detail',
        builder: (context, state) => MedicalRecordDetailScreen(
          recordId: state.pathParameters['recordId']!,
        ),
      ),

      GoRoute(
        path: '${AppRoutes.medicalRecords}/prescription/form',
        name: 'prescription-form',
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'];
          return PrescriptionFormScreen(profileId: profileId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.medicalRecords}/medication/form',
        name: 'medication-form',
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'];
          return MedicationFormScreen(profileId: profileId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.medicalRecords}/lab-report/form',
        name: 'lab-report-form',
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'];
          return LabReportFormScreen(profileId: profileId);
        },
      ),

      GoRoute(
        path: AppRoutes.reminders,
        name: 'reminders',
        builder: (context, state) => const RemindersScreen(),
      ),

      GoRoute(
        path: '${AppRoutes.settings}/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),

      GoRoute(
        path: '${AppRoutes.settings}/import',
        name: 'import',
        builder: (context, state) => const ImportScreen(),
      ),

      GoRoute(
        path: '${AppRoutes.settings}/emergency-card',
        name: 'emergency-card',
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'] ?? '';
          return EmergencyCardScreen(profileId: profileId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.settings}/sync',
        name: 'sync',
        builder: (context, state) => const SyncSettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.vitalsTracking,
        name: 'vitals-tracking',
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'] ?? '';
          return VitalsTrackingScreen(profileId: profileId);
        },
      ),

      GoRoute(
        path: AppRoutes.ocrScan,
        name: 'ocr-scan',
        builder: (context, state) {
          return const OCRScanScreen(ocrType: OCRType.prescription);
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),

    redirect: (context, state) async {
      final currentPath = state.uri.toString();

      // Always allow access to onboarding
      if (currentPath == AppRoutes.onboarding) {
        return null;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final isOnboardingCompleted =
            prefs.getBool('onboarding_completed') ?? false;

        // If onboarding not completed, redirect to onboarding
        if (!isOnboardingCompleted) {
          return AppRoutes.onboarding;
        }

        // Allow access to profile form (needed for mandatory profile creation)
        if (currentPath == AppRoutes.profiles ||
            currentPath == AppRoutes.profileForm) {
          return null;
        }

        // Check if at least one profile exists
        final database = AppDatabase.instance;
        final profilesQuery = await database
            .select(database.familyMemberProfiles)
            .get();
        final hasProfiles = profilesQuery.isNotEmpty;

        // If no profiles exist, redirect to profile creation
        if (!hasProfiles) {
          return AppRoutes.profileForm;
        }

        return null; // Allow access to requested route
      } catch (e) {
        // If there's any error, default to showing onboarding
        return AppRoutes.onboarding;
      }
    },
  );
});

extension GoRouterExtension on GoRouter {
  String get location => routeInformationProvider.value.uri.toString();

  void pushAndClearStack(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
}
