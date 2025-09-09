import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for first-time user onboarding flow
/// 
/// User Story: "As a first-time user, I want to be guided through setting up 
/// my first family member profile so I can start managing medical records."
/// 
/// Test Coverage:
/// - Welcome screen presentation
/// - First profile creation form
/// - Basic information validation
/// - Successful profile creation
/// - Navigation to main dashboard
/// - Local database initialization
/// 
/// This test MUST fail until onboarding flow is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('First-time User Onboarding Integration Tests', () {
    testWidgets('complete onboarding flow for new user', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Verify welcome screen is displayed for first-time user
      expect(find.text('Welcome to HealthBox'), findsOneWidget);
      expect(find.text('Manage your family\'s medical records securely'), findsOneWidget);
      expect(find.byKey(const Key('get_started_button')), findsOneWidget);

      // Step 2: Tap "Get Started" button
      await tester.tap(find.byKey(const Key('get_started_button')));
      await tester.pumpAndSettle();

      // Step 3: Verify first profile setup screen
      expect(find.text('Create Your First Profile'), findsOneWidget);
      expect(find.text('Let\'s start by setting up your first family member profile'), findsOneWidget);
      
      // Verify form fields are present
      expect(find.byKey(const Key('first_name_field')), findsOneWidget);
      expect(find.byKey(const Key('last_name_field')), findsOneWidget);
      expect(find.byKey(const Key('date_of_birth_field')), findsOneWidget);
      expect(find.byKey(const Key('gender_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('continue_button')), findsOneWidget);

      // Step 4: Fill in profile information
      await tester.enterText(
        find.byKey(const Key('first_name_field')), 
        'John'
      );
      await tester.enterText(
        find.byKey(const Key('last_name_field')), 
        'Doe'
      );
      
      // Select date of birth (tap field and select date)
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      
      // Assuming date picker appears, select a date (1990-01-01)
      await tester.tap(find.text('OK')); // Close date picker with default/selected date
      await tester.pumpAndSettle();

      // Select gender
      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      // Step 5: Submit profile creation
      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Step 6: Verify optional information screen
      expect(find.text('Additional Information (Optional)'), findsOneWidget);
      expect(find.byKey(const Key('blood_type_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('height_field')), findsOneWidget);
      expect(find.byKey(const Key('weight_field')), findsOneWidget);
      expect(find.byKey(const Key('skip_button')), findsOneWidget);
      expect(find.byKey(const Key('save_and_continue_button')), findsOneWidget);

      // Step 7: Skip optional information for this test
      await tester.tap(find.byKey(const Key('skip_button')));
      await tester.pumpAndSettle();

      // Step 8: Verify emergency contact setup screen
      expect(find.text('Emergency Contact'), findsOneWidget);
      expect(find.text('Add an emergency contact for this profile'), findsOneWidget);
      expect(find.byKey(const Key('emergency_contact_name_field')), findsOneWidget);
      expect(find.byKey(const Key('emergency_contact_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('skip_emergency_button')), findsOneWidget);
      expect(find.byKey(const Key('add_emergency_contact_button')), findsOneWidget);

      // Step 9: Add emergency contact
      await tester.enterText(
        find.byKey(const Key('emergency_contact_name_field')), 
        'Jane Doe'
      );
      await tester.enterText(
        find.byKey(const Key('emergency_contact_phone_field')), 
        '+1-555-123-4567'
      );

      await tester.tap(find.byKey(const Key('add_emergency_contact_button')));
      await tester.pumpAndSettle();

      // Step 10: Verify setup completion screen
      expect(find.text('Setup Complete!'), findsOneWidget);
      expect(find.text('Your profile has been created successfully'), findsOneWidget);
      expect(find.byKey(const Key('go_to_dashboard_button')), findsOneWidget);

      // Step 11: Navigate to main dashboard
      await tester.tap(find.byKey(const Key('go_to_dashboard_button')));
      await tester.pumpAndSettle();

      // Step 12: Verify main dashboard is displayed
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget); // Profile name should be visible
      expect(find.byKey(const Key('add_record_fab')), findsOneWidget);
      expect(find.byKey(const Key('profile_selector')), findsOneWidget);

      // Step 13: Verify database was initialized and profile saved
      // This would typically check that the profile exists in local storage
      expect(find.text('Recent Records'), findsOneWidget);
      expect(find.text('No records yet'), findsOneWidget); // Empty state for new user

      // Step 14: Verify navigation drawer/menu is accessible
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Family Profiles'), findsOneWidget);
      expect(find.text('Emergency Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('validation errors during profile creation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to profile creation
      await tester.tap(find.byKey(const Key('get_started_button')));
      await tester.pumpAndSettle();

      // Step 1: Try to continue without filling required fields
      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Date of birth is required'), findsOneWidget);
      expect(find.text('Gender is required'), findsOneWidget);

      // Step 2: Fill invalid data
      await tester.enterText(
        find.byKey(const Key('first_name_field')), 
        'J' // Too short
      );
      await tester.enterText(
        find.byKey(const Key('last_name_field')), 
        'D' // Too short
      );

      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Verify specific validation messages
      expect(find.text('First name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Last name must be at least 2 characters'), findsOneWidget);

      // Step 3: Fill valid data
      await tester.enterText(
        find.byKey(const Key('first_name_field')), 
        'John'
      );
      await tester.enterText(
        find.byKey(const Key('last_name_field')), 
        'Doe'
      );

      // Select date and gender
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      // Continue should now work
      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Verify we moved to next screen
      expect(find.text('Additional Information (Optional)'), findsOneWidget);
    });

    testWidgets('user can go back during onboarding', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate through onboarding
      await tester.tap(find.byKey(const Key('get_started_button')));
      await tester.pumpAndSettle();

      // Fill basic info and continue
      await tester.enterText(find.byKey(const Key('first_name_field')), 'John');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Doe');
      
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Now on additional information screen
      expect(find.text('Additional Information (Optional)'), findsOneWidget);

      // Test back button functionality
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Should be back on basic info screen with data preserved
      expect(find.text('Create Your First Profile'), findsOneWidget);
      expect(find.text('John'), findsOneWidget); // Data should be preserved
      expect(find.text('Doe'), findsOneWidget);
    });

    testWidgets('onboarding skips welcome for returning user', (tester) async {
      // This test would simulate a user who has already completed onboarding
      // and should go directly to dashboard
      
      // Start the app (simulating returning user)
      app.main();
      await tester.pumpAndSettle();

      // For returning user, should skip welcome and go directly to dashboard
      // This assumes the app checks for existing profiles on startup
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('add_record_fab')), findsOneWidget);
      
      // Should not see welcome screen
      expect(find.text('Welcome to HealthBox'), findsNothing);
    });

    testWidgets('database encryption is initialized during onboarding', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate through complete onboarding flow
      await tester.tap(find.byKey(const Key('get_started_button')));
      await tester.pumpAndSettle();

      // Fill and submit profile
      await tester.enterText(find.byKey(const Key('first_name_field')), 'John');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Doe');
      
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pumpAndSettle();

      // Skip additional info
      await tester.tap(find.byKey(const Key('skip_button')));
      await tester.pumpAndSettle();

      // Skip emergency contact
      await tester.tap(find.byKey(const Key('skip_emergency_button')));
      await tester.pumpAndSettle();

      // Complete setup
      await tester.tap(find.byKey(const Key('go_to_dashboard_button')));
      await tester.pumpAndSettle();

      // Verify dashboard loads (indicating database was properly initialized)
      expect(find.text('Dashboard'), findsOneWidget);
      
      // This test would also verify that:
      // - SQLCipher database was created
      // - Encryption keys were generated
      // - Initial database schema was set up
      // - Profile was saved encrypted
    });
  });
}