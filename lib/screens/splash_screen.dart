import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alarm/alarm.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../data/database/app_database.dart';
import '../features/reminders/services/notification_alarm_service.dart';
import '../shared/navigation/app_router.dart';

/// Beautiful splash screen with loader while app initializes
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Initializing...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize timezone data
      setState(() => _statusMessage = 'Setting up timezone...');
      await Future.delayed(const Duration(milliseconds: 300));
      tz.initializeTimeZones();

      // Initialize alarm service
      setState(() => _statusMessage = 'Initializing alarms...');
      await Future.delayed(const Duration(milliseconds: 300));
      await Alarm.init();

      // Initialize database
      setState(() => _statusMessage = 'Setting up database...');
      await Future.delayed(const Duration(milliseconds: 300));
      await _initializeDatabase();

      // Initialize notification services
      setState(() => _statusMessage = 'Configuring notifications...');
      await Future.delayed(const Duration(milliseconds: 300));
      await _initializeNotificationServices();

      // Success! Wait a moment then navigate
      setState(() => _statusMessage = 'Ready!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Navigate based on router logic (will check onboarding, profiles, etc.)
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Failed to initialize: ${e.toString()}';
      });
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final database = AppDatabase.instance;
      debugPrint('Got database instance successfully');

      final canConnect = await database.testConnection();
      debugPrint('Database connection test: ${canConnect ? "SUCCESS" : "FAILED"}');

      if (canConnect) {
        debugPrint('HealthBox database is ready!');
        try {
          await database.customStatement(
            'CREATE TABLE IF NOT EXISTS test_table (id INTEGER PRIMARY KEY)',
          );
          await database.customStatement('DROP TABLE IF EXISTS test_table');
          debugPrint('Database table operations test: SUCCESS');
        } catch (tableError) {
          debugPrint('Database table operations test: FAILED - $tableError');
        }
      } else {
        debugPrint('Warning: Database connection failed, app will use fallback');
      }
    } catch (e) {
      debugPrint('Database initialization error: $e');
    }
  }

  Future<void> _initializeNotificationServices() async {
    try {
      debugPrint('Initializing notification services...');

      final notificationAlarmService = NotificationAlarmService();
      final initialized = await notificationAlarmService.initialize();

      if (initialized) {
        try {
          final permissionsGranted = await notificationAlarmService.requestPermissions();
          if (permissionsGranted) {
            debugPrint('Notification permissions granted');
          } else {
            debugPrint('Warning: Some notification permissions were not granted');
          }
        } catch (e) {
          debugPrint('Warning: Failed to request notification permissions: $e');
        }
      }

      debugPrint('Notification services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification services: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon/Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.health_and_safety,
                        size: 70,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App Name
                    Text(
                      'HealthBox',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    Text(
                      'Your Family Health Companion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading Indicator
                    if (!_hasError) ...[
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Status Message
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: _hasError
                              ? Colors.red.shade100
                              : Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Retry button if error
                    if (_hasError) ...[
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _statusMessage = 'Retrying...';
                          });
                          _initializeApp();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
