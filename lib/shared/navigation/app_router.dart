import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/main_app_screen.dart';
import '../../screens/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String profiles = '/profiles';
  static const String medicalRecords = '/medical-records';
  static const String reminders = '/reminders';
  static const String settings = '/settings';
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
    initialLocation: AppRoutes.onboarding,
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
              child: PlaceholderScreen(title: 'Dashboard'),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.profiles,
            name: 'profiles',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Profiles'),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.medicalRecords,
            name: 'medical-records',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Medical Records'),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.reminders,
            name: 'reminders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReminderListScreen(),
            ),
          ),
          
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
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
    
    redirect: (context, state) {
      return null;
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