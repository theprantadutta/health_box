import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for multiple family profiles management
///
/// User Story: "As a parent/caregiver, I want to manage medical records
/// for multiple family members so I can keep track of everyone's health
/// information in one secure app."
///
/// Test Coverage:
/// - Creating multiple family member profiles
/// - Switching between different profiles
/// - Profile data isolation and privacy
/// - Editing existing profiles
/// - Deleting/archiving profiles
/// - Profile-specific medical records
/// - Family member search and filtering
///
/// This test MUST fail until family profiles management is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Multiple Family Profiles Management Integration Tests', () {
    testWidgets('create and manage multiple family member profiles', (
      tester,
    ) async {
      // Start the app and assume initial profile already exists
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Family Profiles section
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();

      // Step 1: Verify Family Profiles screen
      expect(find.text('Family Profiles'), findsOneWidget);
      expect(find.text('Manage your family members'), findsOneWidget);
      expect(find.byKey(const Key('add_profile_fab')), findsOneWidget);

      // Should see existing profile from onboarding
      expect(find.byKey(const Key('profile_card_0')), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);

      // Step 2: Add second family member (spouse)
      await tester.tap(find.byKey(const Key('add_profile_fab')));
      await tester.pumpAndSettle();

      expect(find.text('Add Family Member'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('first_name_field')), 'Jane');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Doe');
      await tester.enterText(
        find.byKey(const Key('middle_name_field')),
        'Marie',
      );

      // Set date of birth
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Select gender
      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      // Add relationship
      await tester.tap(find.byKey(const Key('relationship_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spouse'));
      await tester.pumpAndSettle();

      // Save profile
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Step 3: Verify second profile was added
      expect(find.byKey(const Key('profile_card_1')), findsOneWidget);
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('Spouse'), findsOneWidget);

      // Step 4: Add child profile
      await tester.tap(find.byKey(const Key('add_profile_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('first_name_field')),
        'Tommy',
      );
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Doe');

      // Child date of birth (more recent)
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('relationship_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Child'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Step 5: Verify all three profiles are displayed
      expect(find.byKey(const Key('profile_card_0')), findsOneWidget);
      expect(find.byKey(const Key('profile_card_1')), findsOneWidget);
      expect(find.byKey(const Key('profile_card_2')), findsOneWidget);
      expect(find.text('Tommy Doe'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);

      // Step 6: Test profile switching from dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be on dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Test profile selector dropdown
      await tester.tap(find.byKey(const Key('profile_selector')));
      await tester.pumpAndSettle();

      // Should see all profiles in dropdown
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('Tommy Doe'), findsOneWidget);

      // Select Jane's profile
      await tester.tap(find.text('Jane Marie Doe'));
      await tester.pumpAndSettle();

      // Verify profile switched
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('Current Profile'), findsOneWidget);
    });

    testWidgets('edit existing family member profile', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Family Profiles
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();

      // Step 1: Edit first profile
      await tester.tap(find.byKey(const Key('profile_card_0')));
      await tester.pumpAndSettle();

      // Should see profile details screen
      expect(find.text('Profile Details'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      // Step 2: Modify profile information
      expect(find.text('Edit Profile'), findsOneWidget);

      // Clear and update middle name
      await tester.enterText(
        find.byKey(const Key('middle_name_field')),
        'Michael',
      );

      // Update blood type
      await tester.tap(find.byKey(const Key('blood_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('O+'));
      await tester.pumpAndSettle();

      // Update height and weight
      await tester.enterText(find.byKey(const Key('height_field')), '180');
      await tester.enterText(find.byKey(const Key('weight_field')), '75');

      // Add emergency contact
      await tester.enterText(
        find.byKey(const Key('emergency_contact_field')),
        'Dr. Smith - (555) 999-8888',
      );

      // Save changes
      await tester.tap(find.byKey(const Key('save_changes_button')));
      await tester.pumpAndSettle();

      // Step 3: Verify changes were saved
      expect(find.text('Profile updated successfully'), findsOneWidget);
      expect(find.text('John Michael Doe'), findsOneWidget);
      expect(find.text('O+'), findsOneWidget);
      expect(find.text('180 cm'), findsOneWidget);
      expect(find.text('75 kg'), findsOneWidget);
    });

    testWidgets('profile data isolation between family members', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Add medical record to John's profile
      await tester.tap(find.byKey(const Key('profile_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Add a prescription record
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prescription'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')),
        'Lisinopril',
      );
      await tester.enterText(find.byKey(const Key('dosage_field')), '10mg');

      await tester.tap(find.byKey(const Key('save_record_button')));
      await tester.pumpAndSettle();

      // Verify record appears in John's dashboard
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('10mg'), findsOneWidget);

      // Step 2: Switch to Jane's profile
      await tester.tap(find.byKey(const Key('profile_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jane Marie Doe'));
      await tester.pumpAndSettle();

      // Step 3: Verify Jane's profile doesn't show John's records
      expect(find.text('Lisinopril'), findsNothing);
      expect(find.text('No records yet'), findsOneWidget);

      // Step 4: Add different record to Jane's profile
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lab Report'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('test_name_field')),
        'Blood Test',
      );
      await tester.enterText(find.byKey(const Key('results_field')), 'Normal');

      await tester.tap(find.byKey(const Key('save_record_button')));
      await tester.pumpAndSettle();

      // Verify Jane's record appears
      expect(find.text('Blood Test'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);

      // Step 5: Switch back to John and verify isolation
      await tester.tap(find.byKey(const Key('profile_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // John should see his record but not Jane's
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Blood Test'), findsNothing);
    });

    testWidgets('search and filter family profiles', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Family Profiles
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();

      // Step 1: Test search functionality
      expect(find.byKey(const Key('profile_search_field')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('profile_search_field')),
        'Jane',
      );
      await tester.pumpAndSettle();

      // Should only show Jane's profile
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);
      expect(find.text('Tommy Doe'), findsNothing);

      // Step 2: Clear search
      await tester.enterText(find.byKey(const Key('profile_search_field')), '');
      await tester.pumpAndSettle();

      // All profiles should be visible again
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Tommy Doe'), findsOneWidget);

      // Step 3: Test filter by relationship
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      expect(find.text('Filter Profiles'), findsOneWidget);
      await tester.tap(find.byKey(const Key('relationship_filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Child'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_filter_button')));
      await tester.pumpAndSettle();

      // Should only show child profiles
      expect(find.text('Tommy Doe'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);
      expect(find.text('Jane Marie Doe'), findsNothing);

      // Clear filter
      await tester.tap(find.byKey(const Key('clear_filter_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('archive and restore family member profile', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Family Profiles
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();

      // Step 1: Archive a profile
      await tester.longPress(find.byKey(const Key('profile_card_2'))); // Tommy
      await tester.pumpAndSettle();

      expect(find.text('Profile Options'), findsOneWidget);
      await tester.tap(find.text('Archive Profile'));
      await tester.pumpAndSettle();

      // Confirm archive
      expect(find.text('Archive Profile?'), findsOneWidget);
      expect(
        find.text('This will hide the profile but keep all data.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('confirm_archive_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify profile is archived (hidden from main view)
      expect(find.text('Tommy Doe'), findsNothing);
      expect(find.text('Profile archived successfully'), findsOneWidget);

      // Step 3: View archived profiles
      await tester.tap(find.byKey(const Key('menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Archived'));
      await tester.pumpAndSettle();

      // Should see archived profile
      expect(find.text('Archived Profiles'), findsOneWidget);
      expect(find.text('Tommy Doe'), findsOneWidget);
      expect(find.byIcon(Icons.archive), findsOneWidget);

      // Step 4: Restore archived profile
      await tester.tap(find.byKey(const Key('restore_profile_button')));
      await tester.pumpAndSettle();

      expect(find.text('Restore Profile?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_restore_button')));
      await tester.pumpAndSettle();

      // Step 5: Verify profile is restored
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Tommy Doe'), findsOneWidget);
      expect(find.text('Profile restored successfully'), findsOneWidget);
    });

    testWidgets('profile validation and error handling', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add new profile
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add_profile_fab')));
      await tester.pumpAndSettle();

      // Step 1: Test duplicate name validation
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

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Should show duplicate warning
      expect(
        find.text('A profile with this name already exists'),
        findsOneWidget,
      );
      expect(find.text('Continue anyway?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();

      // Step 2: Test invalid date validation
      await tester.enterText(find.byKey(const Key('first_name_field')), 'Baby');

      // Try to set future date of birth
      await tester.tap(find.byKey(const Key('date_of_birth_field')));
      await tester.pumpAndSettle();
      // (Would select future date in real implementation)

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Date of birth cannot be in the future'),
        findsOneWidget,
      );
    });

    testWidgets('family tree view and relationships', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Family Profiles
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Profiles'));
      await tester.pumpAndSettle();

      // Step 1: Switch to family tree view
      await tester.tap(find.byKey(const Key('view_toggle_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Family Tree'));
      await tester.pumpAndSettle();

      // Step 2: Verify family tree visualization
      expect(find.text('Family Tree'), findsOneWidget);
      expect(find.byKey(const Key('family_tree_view')), findsOneWidget);

      // Should show relationships visually
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Marie Doe'), findsOneWidget);
      expect(find.text('Tommy Doe'), findsOneWidget);

      // Relationship lines/connections should be visible
      expect(find.byKey(const Key('relationship_line_spouse')), findsOneWidget);
      expect(find.byKey(const Key('relationship_line_child')), findsWidgets);

      // Step 3: Test interactive family tree
      await tester.tap(find.text('Tommy Doe'));
      await tester.pumpAndSettle();

      // Should highlight family connections
      expect(find.text('Parents: John Doe, Jane Marie Doe'), findsOneWidget);
    });
  });
}
