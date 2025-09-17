import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for offline functionality
///
/// User Story: "As a user, I want the app to work completely offline so I can
/// access and manage medical records even without internet connectivity."
///
/// Test Coverage:
/// - Full app functionality without internet connection
/// - Local data persistence and retrieval
/// - Offline data creation, editing, and deletion
/// - Search and filtering in offline mode
/// - Reminder notifications without internet
/// - Data integrity during offline operations
/// - Sync queue management for offline changes
/// - Error handling for network-dependent features
///
/// This test MUST fail until offline-first architecture is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Functionality Integration Tests', () {
    testWidgets('app launches and functions completely offline', (
      tester,
    ) async {
      // Simulate offline environment by disabling network connectivity
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async {
          // Return no connectivity
          return const StandardMethodCodec().encodeSuccessEnvelope('none');
        },
      );

      // Start the app in offline mode
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Verify app launches without internet
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('offline_indicator')), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);

      // Step 2: Verify existing data is accessible offline
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byKey(const Key('profile_selector')), findsOneWidget);

      // Medical records should be visible from local storage
      expect(find.byKey(const Key('recent_records_list')), findsOneWidget);

      // Step 3: Test navigation in offline mode
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Family Profiles'), findsOneWidget);
      expect(find.text('Emergency Cards'), findsOneWidget);

      // Network-dependent features should show offline notice
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Step 4: Verify medical records work offline
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.byKey(const Key('records_list')), findsOneWidget);
      expect(find.byKey(const Key('search_records_field')), findsOneWidget);
      expect(find.byKey(const Key('add_record_fab')), findsOneWidget);
    });

    testWidgets('create medical records while offline', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate to add new record
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();

      // Step 1: Create prescription record offline
      await tester.tap(find.text('Prescription'));
      await tester.pumpAndSettle();

      expect(find.text('New Prescription'), findsOneWidget);
      expect(find.byKey(const Key('offline_save_notice')), findsOneWidget);
      expect(find.text('Changes will be saved locally'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('medication_name_field')),
        'Ibuprofen',
      );
      await tester.enterText(find.byKey(const Key('dosage_field')), '200mg');
      await tester.enterText(
        find.byKey(const Key('frequency_field')),
        'Every 8 hours as needed',
      );
      await tester.enterText(
        find.byKey(const Key('prescribing_doctor_field')),
        'Dr. Johnson',
      );

      await tester.tap(find.byKey(const Key('save_record_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify record was saved locally
      expect(find.text('Record saved offline'), findsOneWidget);
      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.text('200mg'), findsOneWidget);

      // Should show sync pending indicator
      expect(find.byIcon(Icons.sync_disabled), findsOneWidget);
      expect(find.text('Sync pending'), findsOneWidget);

      // Step 3: Create lab report record
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lab Report'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('test_name_field')),
        'Complete Blood Count',
      );
      await tester.enterText(
        find.byKey(const Key('test_results_field')),
        'All values within normal range',
      );
      await tester.enterText(
        find.byKey(const Key('ordering_physician_field')),
        'Dr. Smith',
      );

      await tester.tap(find.byKey(const Key('save_record_button')));
      await tester.pumpAndSettle();

      // Step 4: Verify multiple offline records
      expect(find.text('Complete Blood Count'), findsOneWidget);
      expect(find.text('Ibuprofen'), findsOneWidget);

      // Should show multiple items pending sync
      expect(find.text('2 items pending sync'), findsOneWidget);
    });

    testWidgets('edit and delete records while offline', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Step 1: Edit existing record offline
      await tester.tap(find.text('Ibuprofen'));
      await tester.pumpAndSettle();

      expect(find.text('Prescription Details'), findsOneWidget);
      await tester.tap(find.byKey(const Key('edit_record_button')));
      await tester.pumpAndSettle();

      // Modify dosage
      await tester.enterText(find.byKey(const Key('dosage_field')), '400mg');
      await tester.enterText(
        find.byKey(const Key('instructions_field')),
        'Take with food to avoid stomach upset',
      );

      await tester.tap(find.byKey(const Key('save_changes_button')));
      await tester.pumpAndSettle();

      // Verify changes saved offline
      expect(find.text('Changes saved offline'), findsOneWidget);
      expect(find.text('400mg'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget); // Edit indicator

      // Step 2: Delete record offline
      await tester.longPress(find.text('Complete Blood Count'));
      await tester.pumpAndSettle();

      expect(find.text('Record Options'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Record?'), findsOneWidget);
      expect(
        find.text('This will be deleted when back online'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      // Verify record marked for deletion
      expect(find.text('Marked for deletion'), findsOneWidget);
      expect(find.text('Complete Blood Count'), findsNothing);

      // Should show in pending sync queue
      expect(find.text('1 deletion pending sync'), findsOneWidget);
    });

    testWidgets('search and filter work offline', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate to medical records
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Step 1: Test search functionality offline
      await tester.enterText(
        find.byKey(const Key('search_records_field')),
        'Ibuprofen',
      );
      await tester.pumpAndSettle();

      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.text('Search results from local data'), findsOneWidget);

      // Step 2: Test filtering offline
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      expect(find.text('Filter Records'), findsOneWidget);
      await tester.tap(find.byKey(const Key('record_type_filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prescription'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_filter_button')));
      await tester.pumpAndSettle();

      // Should only show prescription records
      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.text('Filtered locally'), findsOneWidget);

      // Step 3: Test date range filtering offline
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('date_range_filter')));
      await tester.pumpAndSettle();

      // Select last 30 days
      await tester.tap(find.text('Last 30 days'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_filter_button')));
      await tester.pumpAndSettle();

      expect(find.text('Showing records from last 30 days'), findsOneWidget);
    });

    testWidgets('reminder notifications work offline', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: Create reminder offline
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      expect(find.text('New Reminder'), findsOneWidget);
      expect(
        find.text('Local notifications only while offline'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('reminder_title_field')),
        'Take Morning Medication',
      );
      await tester.enterText(
        find.byKey(const Key('reminder_description_field')),
        'Ibuprofen 400mg with breakfast',
      );

      // Set time
      await tester.tap(find.byKey(const Key('reminder_time_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Set frequency
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify reminder saved locally
      expect(find.text('Reminder saved offline'), findsOneWidget);
      expect(find.text('Take Morning Medication'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
      expect(find.text('Local only'), findsOneWidget);

      // Step 3: Test reminder functionality offline
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      // Toggle reminder on/off
      await tester.tap(find.byKey(const Key('reminder_toggle_0')));
      await tester.pumpAndSettle();

      expect(find.text('Reminder updated offline'), findsOneWidget);
    });

    testWidgets('emergency card generation works offline', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate to emergency cards
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emergency Cards'));
      await tester.pumpAndSettle();

      // Step 1: Generate emergency card offline
      expect(find.text('Emergency Cards'), findsOneWidget);
      expect(find.text('Generated from local data'), findsOneWidget);

      await tester.tap(find.byKey(const Key('generate_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Generate Emergency Card'), findsOneWidget);

      // Select profile
      await tester.tap(find.byKey(const Key('profile_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Select format
      await tester.tap(find.byKey(const Key('format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF Card'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('generate_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify card generation from local data
      expect(find.text('Emergency card generated'), findsOneWidget);
      expect(find.text('Using local data only'), findsOneWidget);
      expect(find.byKey(const Key('view_card_button')), findsOneWidget);
      expect(find.byKey(const Key('share_card_button')), findsOneWidget);

      // Note: Sharing would be limited offline
      await tester.tap(find.byKey(const Key('share_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Limited sharing options offline'), findsOneWidget);
    });

    testWidgets('offline sync queue management', (tester) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings to check sync status
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Step 1: Check sync queue status
      await tester.tap(find.text('Sync Status'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Queue'), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);

      // Should show pending items
      expect(find.text('Pending Changes:'), findsOneWidget);
      expect(find.text('• 1 new prescription'), findsOneWidget);
      expect(find.text('• 1 edited prescription'), findsOneWidget);
      expect(find.text('• 1 deleted lab report'), findsOneWidget);
      expect(find.text('• 1 new reminder'), findsOneWidget);

      // Step 2: Test manual sync attempt while offline
      await tester.tap(find.byKey(const Key('sync_now_button')));
      await tester.pumpAndSettle();

      expect(find.text('Cannot sync while offline'), findsOneWidget);
      expect(
        find.text('Changes will sync when connection restored'),
        findsOneWidget,
      );

      // Step 3: Clear sync queue option
      expect(find.byKey(const Key('clear_queue_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear_queue_button')));
      await tester.pumpAndSettle();

      expect(find.text('Clear Sync Queue?'), findsOneWidget);
      expect(
        find.text('This will discard all pending changes'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('transition from offline to online mode', (tester) async {
      // Start offline
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offline_indicator')), findsOneWidget);

      // Step 1: Simulate connection restored
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('wifi'),
      );

      // Trigger connectivity check
      await tester.tap(find.byKey(const Key('check_connection_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify online mode activated
      expect(find.text('Connection restored'), findsOneWidget);
      expect(find.byKey(const Key('online_indicator')), findsOneWidget);
      expect(find.text('Syncing pending changes...'), findsOneWidget);

      // Wait for sync to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 3: Verify sync completed
      expect(find.text('Sync completed'), findsOneWidget);
      expect(find.text('All changes synced successfully'), findsOneWidget);

      // Sync indicators should be removed
      expect(find.byIcon(Icons.sync_disabled), findsNothing);
      expect(find.text('Sync pending'), findsNothing);

      // Step 4: Test that online features are restored
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Cloud sync should be available again
      expect(find.text('Google Drive Sync'), findsOneWidget);
      expect(find.byKey(const Key('sync_settings_button')), findsOneWidget);
    });

    testWidgets('data integrity maintained during offline operations', (
      tester,
    ) async {
      // Set offline mode
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async =>
            const StandardMethodCodec().encodeSuccessEnvelope('none'),
      );

      app.main();
      await tester.pumpAndSettle();

      // Step 1: Create multiple records with relationships
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medication'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')),
        'Metformin',
      );
      await tester.tap(find.byKey(const Key('save_record_button')));
      await tester.pumpAndSettle();

      // Create related reminder
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reminder_title_field')),
        'Take Metformin',
      );

      // Link to medication
      await tester.tap(find.byKey(const Key('link_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metformin'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify relationships maintained offline
      expect(find.text('Take Metformin'), findsOneWidget);
      expect(find.text('Linked to: Metformin'), findsOneWidget);

      // Step 3: Test data consistency during operations
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Verify record exists
      expect(find.text('Metformin'), findsOneWidget);

      // Step 4: Test referential integrity
      await tester.longPress(find.text('Metformin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should warn about linked reminders
      expect(find.text('This medication has linked reminders'), findsOneWidget);
      expect(find.text('Delete reminders too?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();

      // Data integrity preserved
      expect(find.text('Metformin'), findsOneWidget);
    });
  });
}
