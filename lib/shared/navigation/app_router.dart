import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_providers.dart';
import '../animations/page_transitions.dart';

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
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

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
  const PlaceholderScreen({
    super.key,
    required this.title,
  });
  
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
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
      
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainAppScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.profiles,
            name: 'profiles',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'form',
                name: 'profile-form',
                pageBuilder: (context, state) => buildPremiumPage(
                  child: const ProfileFormScreen(),
                  transitionType: PageTransitionType.healthSlide,
                  healthContext: 'profiles',
                ),
              ),
            ],
          ),
          
          GoRoute(
            path: AppRoutes.medicalRecords,
            name: 'medical-records',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MedicalRecordListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'detail/:recordId',
                name: 'medical-record-detail',
                pageBuilder: (context, state) => buildPremiumPage(
                  child: MedicalRecordDetailScreen(
                    recordId: state.pathParameters['recordId']!,
                  ),
                  transitionType: PageTransitionType.cardFlip,
                  healthContext: 'medical_records',
                ),
              ),
              GoRoute(
                path: 'prescription/form',
                name: 'prescription-form',
                pageBuilder: (context, state) {
                  final profileId = state.uri.queryParameters['profileId'];
                  return buildPremiumPage(
                    child: PrescriptionFormScreen(profileId: profileId),
                    transitionType: PageTransitionType.healthSlide,
                    healthContext: 'medication',
                  );
                },
              ),
              GoRoute(
                path: 'medication/form',
                name: 'medication-form',
                pageBuilder: (context, state) {
                  final profileId = state.uri.queryParameters['profileId'];
                  return buildPremiumPage(
                    child: MedicationFormScreen(profileId: profileId),
                    transitionType: PageTransitionType.morphing,
                    healthContext: 'medication',
                  );
                },
              ),
              GoRoute(
                path: 'lab-report/form',
                name: 'lab-report-form',
                pageBuilder: (context, state) {
                  final profileId = state.uri.queryParameters['profileId'];
                  return buildPremiumPage(
                    child: LabReportFormScreen(profileId: profileId),
                    transitionType: PageTransitionType.wave,
                    healthContext: 'nutrition',
                  );
                },
              ),
            ],
          ),
          
          GoRoute(
            path: AppRoutes.reminders,
            name: 'reminders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: settings.SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'export',
                name: 'export',
                pageBuilder: (context, state) => buildPremiumPage(
                  child: const ExportScreen(),
                  transitionType: PageTransitionType.slide,
                  healthContext: 'settings',
                ),
              ),
              GoRoute(
                path: 'import',
                name: 'import',
                pageBuilder: (context, state) => buildPremiumPage(
                  child: const ImportScreen(),
                  transitionType: PageTransitionType.slide,
                  healthContext: 'settings',
                ),
              ),
              GoRoute(
                path: 'emergency-card',
                name: 'emergency-card',
                pageBuilder: (context, state) {
                  final profileId = state.uri.queryParameters['profileId'] ?? '';
                  return buildPremiumPage(
                    child: EmergencyCardScreen(profileId: profileId),
                    transitionType: PageTransitionType.cardFlip,
                    healthContext: 'emergency',
                  );
                },
              ),
              GoRoute(
                path: 'sync',
                name: 'sync',
                pageBuilder: (context, state) => buildPremiumPage(
                  child: const SyncSettingsScreen(),
                  transitionType: PageTransitionType.breathe,
                  healthContext: 'wellness',
                ),
              ),
            ],
          ),
          
          // Additional screens not in main navigation
          GoRoute(
            path: AppRoutes.vitalsTracking,
            name: 'vitals-tracking',
            pageBuilder: (context, state) {
              final profileId = state.uri.queryParameters['profileId'] ?? '';
              return buildPremiumPage(
                child: VitalsTrackingScreen(profileId: profileId),
                transitionType: PageTransitionType.wave,
                healthContext: 'fitness',
              );
            },
          ),
          
          GoRoute(
            path: AppRoutes.ocrScan,
            name: 'ocr-scan',
            pageBuilder: (context, state) => buildPremiumPage(
              child: const OCRScanScreen(
                ocrType: OCRType.prescription, // Default type
              ),
              transitionType: PageTransitionType.dissolve,
              healthContext: 'medication',
            ),
          ),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
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
      // Check if user is accessing onboarding page
      if (state.uri.toString() == AppRoutes.onboarding) {
        return null; // Allow access to onboarding
      }

      // Check if onboarding is completed
      try {
        final onboardingCompleted = ref.read(onboardingCompletedProvider);
        return onboardingCompleted.when(
          data: (isCompleted) => isCompleted ? null : AppRoutes.onboarding,
          loading: () => AppRoutes.onboarding,
          error: (_, __) => AppRoutes.onboarding,
        );
      } catch (e) {
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