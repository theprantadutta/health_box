import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for Google Drive synchronization functionality
/// 
/// User Story: "As a user, I want to optionally sync my medical data 
/// to Google Drive so I can access my records from multiple devices 
/// and have a secure backup in the cloud."
/// 
/// Test Coverage:
/// - Google Drive authentication and authorization
/// - Initial sync setup and configuration
/// - Uploading local data to Google Drive
/// - Downloading and syncing data from Google Drive
/// - Conflict resolution between local and cloud data
/// - Selective sync with privacy controls
/// - Sync status monitoring and error handling
/// - Encryption of data before cloud storage
/// 
/// This test MUST fail until Google Drive sync is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Google Drive Sync Integration Tests', () {
    testWidgets('setup Google Drive sync authentication', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Verify sync setup screen
      expect(find.text('Google Drive Sync'), findsOneWidget);
      expect(find.text('Secure cloud backup and sync'), findsOneWidget);
      expect(find.text('Status: Not Connected'), findsOneWidget);
      expect(find.byKey(const Key('connect_google_drive_button')), findsOneWidget);

      // Should show sync benefits
      expect(find.text('✓ Access records from any device'), findsOneWidget);
      expect(find.text('✓ Automatic encrypted backup'), findsOneWidget);
      expect(find.text('✓ Share data securely with family'), findsOneWidget);
      expect(find.text('✓ Never lose your medical data'), findsOneWidget);

      // Step 2: Initiate Google Drive connection
      await tester.tap(find.byKey(const Key('connect_google_drive_button')));
      await tester.pumpAndSettle();

      expect(find.text('Connect to Google Drive'), findsOneWidget);
      expect(find.text('HealthBox needs permission to store encrypted medical data'), findsOneWidget);

      // Should show permissions requested
      expect(find.text('Permissions Required:'), findsOneWidget);
      expect(find.text('• Create and access HealthBox folder'), findsOneWidget);
      expect(find.text('• Upload encrypted medical records'), findsOneWidget);
      expect(find.text('• Download your own data only'), findsOneWidget);

      await tester.tap(find.byKey(const Key('authorize_google_button')));
      await tester.pumpAndSettle();

      // Step 3: Mock Google OAuth flow
      expect(find.text('Google Sign-In'), findsOneWidget);
      // In real implementation, this would open Google OAuth
      await tester.tap(find.byKey(const Key('mock_google_signin_success')));
      await tester.pumpAndSettle();

      // Step 4: Verify successful connection
      expect(find.text('Google Drive Connected'), findsOneWidget);
      expect(find.text('Status: Connected'), findsOneWidget);
      expect(find.text('Account: john.doe@gmail.com'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);

      // Should show sync configuration options
      expect(find.text('Sync Configuration'), findsOneWidget);
      expect(find.byKey(const Key('auto_sync_toggle')), findsOneWidget);
      expect(find.byKey(const Key('sync_frequency_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('wifi_only_toggle')), findsOneWidget);
    });

    testWidgets('configure sync settings and preferences', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Assume Google Drive is already connected
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Configure auto-sync settings
      expect(find.text('Automatic Sync'), findsOneWidget);
      await tester.tap(find.byKey(const Key('auto_sync_toggle')));
      await tester.pumpAndSettle();

      // Set sync frequency
      await tester.tap(find.byKey(const Key('sync_frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every 6 hours'));
      await tester.pumpAndSettle();

      // Enable WiFi-only sync
      await tester.tap(find.byKey(const Key('wifi_only_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Sync only on WiFi to save mobile data'), findsOneWidget);

      // Step 2: Configure what to sync
      expect(find.text('Data to Sync'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('sync_profiles_toggle')));
      await tester.tap(find.byKey(const Key('sync_medical_records_toggle')));
      await tester.tap(find.byKey(const Key('sync_reminders_toggle')));
      await tester.pumpAndSettle();

      // Configure selective profile sync
      await tester.tap(find.byKey(const Key('select_profiles_button')));
      await tester.pumpAndSettle();

      expect(find.text('Select Profiles to Sync'), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_john_toggle')));
      await tester.tap(find.byKey(const Key('profile_jane_toggle')));
      // Leave child profile unsynced for privacy
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_profile_selection_button')));
      await tester.pumpAndSettle();

      // Step 3: Configure privacy and encryption settings
      expect(find.text('Privacy & Security'), findsOneWidget);
      
      // Verify encryption is always enabled
      expect(find.text('End-to-end encryption: Enabled'), findsOneWidget);
      expect(find.text('Your data is encrypted before leaving your device'), findsOneWidget);
      
      // Configure additional privacy options
      await tester.tap(find.byKey(const Key('exclude_attachments_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Attachments will be stored locally only'), findsOneWidget);

      // Step 4: Save sync configuration
      await tester.tap(find.byKey(const Key('save_sync_settings_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sync settings saved'), findsOneWidget);
      expect(find.text('Next sync: In 6 hours'), findsOneWidget);
    });

    testWidgets('perform initial sync upload to Google Drive', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Initiate first sync
      expect(find.text('Initial Sync'), findsOneWidget);
      expect(find.text('Upload your existing data to Google Drive'), findsOneWidget);
      expect(find.byKey(const Key('start_initial_sync_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('start_initial_sync_button')));
      await tester.pumpAndSettle();

      // Step 2: Show sync preparation
      expect(find.text('Preparing Sync...'), findsOneWidget);
      expect(find.text('Analyzing local data'), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show what will be synced
      expect(find.text('Sync Summary'), findsOneWidget);
      expect(find.text('2 profiles to upload'), findsOneWidget);
      expect(find.text('15 medical records to upload'), findsOneWidget);
      expect(find.text('8 reminders to upload'), findsOneWidget);
      expect(find.text('Estimated upload size: 2.4 MB'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm_sync_button')));
      await tester.pumpAndSettle();

      // Step 3: Monitor sync progress
      expect(find.text('Syncing to Google Drive...'), findsOneWidget);
      expect(find.byKey(const Key('sync_progress_bar')), findsOneWidget);

      // Should show detailed progress
      expect(find.text('Encrypting data...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Uploading profiles... (1/2)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Uploading medical records... (8/15)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Uploading reminders... (8/8)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Finalizing sync...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 4: Verify sync completion
      expect(find.text('Initial Sync Complete!'), findsOneWidget);
      expect(find.text('✓ 2 profiles uploaded'), findsOneWidget);
      expect(find.text('✓ 15 medical records uploaded'), findsOneWidget);
      expect(find.text('✓ 8 reminders uploaded'), findsOneWidget);
      expect(find.text('Last sync: Just now'), findsOneWidget);

      // Should update sync status
      expect(find.text('Status: Synced'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('handle sync conflicts between local and cloud data', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate a sync conflict scenario
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Trigger sync that detects conflicts
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();

      expect(find.text('Checking for updates...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Show conflict detection
      expect(find.text('Sync Conflicts Detected'), findsOneWidget);
      expect(find.text('Some records have been modified both locally and in the cloud'), findsOneWidget);
      
      expect(find.text('3 conflicts need resolution'), findsOneWidget);
      expect(find.byKey(const Key('resolve_conflicts_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('resolve_conflicts_button')));
      await tester.pumpAndSettle();

      // Step 3: Resolve individual conflicts
      expect(find.text('Resolve Sync Conflicts'), findsOneWidget);
      
      // First conflict - prescription record
      expect(find.text('Conflict 1 of 3'), findsOneWidget);
      expect(find.text('Prescription: Lisinopril'), findsOneWidget);
      expect(find.text('Modified locally and in cloud'), findsOneWidget);

      // Show local vs cloud versions
      expect(find.text('Local Version'), findsOneWidget);
      expect(find.text('Dosage: 10mg'), findsOneWidget);
      expect(find.text('Modified: 2 hours ago'), findsOneWidget);

      expect(find.text('Cloud Version'), findsOneWidget);
      expect(find.text('Dosage: 5mg'), findsOneWidget);
      expect(find.text('Modified: 1 hour ago'), findsOneWidget);

      // Resolution options
      expect(find.byKey(const Key('use_local_button')), findsOneWidget);
      expect(find.byKey(const Key('use_cloud_button')), findsOneWidget);
      expect(find.byKey(const Key('merge_button')), findsOneWidget);

      // Choose to use cloud version (more recent)
      await tester.tap(find.byKey(const Key('use_cloud_button')));
      await tester.pumpAndSettle();

      // Step 4: Continue with remaining conflicts
      expect(find.text('Conflict 2 of 3'), findsOneWidget);
      expect(find.text('Medical Record: Lab Report'), findsOneWidget);

      // Choose to merge this conflict
      await tester.tap(find.byKey(const Key('merge_button')));
      await tester.pumpAndSettle();

      // Should show merge preview
      expect(find.text('Merge Preview'), findsOneWidget);
      expect(find.text('Combined data from both versions'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('confirm_merge_button')));
      await tester.pumpAndSettle();

      // Final conflict
      expect(find.text('Conflict 3 of 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('use_local_button')));
      await tester.pumpAndSettle();

      // Step 5: Complete conflict resolution
      expect(find.text('All Conflicts Resolved'), findsOneWidget);
      expect(find.text('Applying changes...'), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Sync Completed'), findsOneWidget);
      expect(find.text('✓ Conflicts resolved successfully'), findsOneWidget);
      expect(find.text('✓ Data synchronized'), findsOneWidget);
    });

    testWidgets('download and restore data from Google Drive', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate restoring data on a new device
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Check for cloud data
      expect(find.text('Restore from Google Drive'), findsOneWidget);
      expect(find.text('Found existing data in your Google Drive'), findsOneWidget);
      expect(find.byKey(const Key('restore_from_cloud_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('restore_from_cloud_button')));
      await tester.pumpAndSettle();

      // Step 2: Show available cloud data
      expect(find.text('Available Cloud Data'), findsOneWidget);
      expect(find.text('Last backup: 2 days ago'), findsOneWidget);
      expect(find.text('2 family profiles'), findsOneWidget);
      expect(find.text('15 medical records'), findsOneWidget);
      expect(find.text('8 medication reminders'), findsOneWidget);
      expect(find.text('Size: 2.4 MB'), findsOneWidget);

      // Step 3: Configure restore options
      expect(find.text('Restore Options'), findsOneWidget);
      
      // Choose what to restore
      await tester.tap(find.byKey(const Key('restore_profiles_toggle')));
      await tester.tap(find.byKey(const Key('restore_records_toggle')));
      await tester.tap(find.byKey(const Key('restore_reminders_toggle')));
      await tester.pumpAndSettle();

      // Choose restore behavior
      await tester.tap(find.byKey(const Key('restore_behavior_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Merge with existing data'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('start_restore_button')));
      await tester.pumpAndSettle();

      // Step 4: Monitor restore progress
      expect(find.text('Restoring from Google Drive...'), findsOneWidget);
      expect(find.byKey(const Key('restore_progress_bar')), findsOneWidget);

      expect(find.text('Downloading encrypted data...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Decrypting data...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Restoring profiles... (1/2)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Restoring records... (10/15)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Merging data...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 5: Verify restore completion
      expect(find.text('Restore Complete!'), findsOneWidget);
      expect(find.text('✓ 2 profiles restored'), findsOneWidget);
      expect(find.text('✓ 15 medical records restored'), findsOneWidget);
      expect(find.text('✓ 8 reminders restored'), findsOneWidget);
      expect(find.text('✓ No conflicts detected'), findsOneWidget);

      expect(find.text('Status: Synced'), findsOneWidget);
    });

    testWidgets('monitor sync status and handle errors', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync status
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: View detailed sync status
      await tester.tap(find.byKey(const Key('sync_status_details')));
      await tester.pumpAndSettle();

      expect(find.text('Sync Status Details'), findsOneWidget);
      expect(find.text('Connection: Active'), findsOneWidget);
      expect(find.text('Last sync: 2 hours ago'), findsOneWidget);
      expect(find.text('Next auto sync: In 4 hours'), findsOneWidget);
      expect(find.text('Data usage this month: 45 MB'), findsOneWidget);

      // Step 2: View sync history
      expect(find.text('Recent Sync Activity'), findsOneWidget);
      expect(find.text('Jan 15, 2:30 PM - Upload complete (3 records)'), findsOneWidget);
      expect(find.text('Jan 15, 8:15 AM - Auto sync complete'), findsOneWidget);
      expect(find.text('Jan 14, 6:45 PM - Download complete (1 record)'), findsOneWidget);

      // Step 3: Simulate sync error
      await tester.tap(find.byKey(const Key('force_sync_error_button')));
      await tester.pumpAndSettle();

      // Simulate network error during sync
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sync Error'), findsOneWidget);
      expect(find.text('Failed to connect to Google Drive'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);

      // Should show error details and retry option
      expect(find.text('Error: Network timeout'), findsOneWidget);
      expect(find.byKey(const Key('retry_sync_button')), findsOneWidget);
      expect(find.byKey(const Key('sync_offline_mode_button')), findsOneWidget);

      // Step 4: Test automatic retry
      await tester.tap(find.byKey(const Key('retry_sync_button')));
      await tester.pumpAndSettle();

      expect(find.text('Retrying sync...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Simulate successful retry
      expect(find.text('Sync successful'), findsOneWidget);
      expect(find.text('Status: Synced'), findsOneWidget);

      // Step 5: Test sync quota/storage limits
      await tester.tap(find.byKey(const Key('storage_usage_button')));
      await tester.pumpAndSettle();

      expect(find.text('Google Drive Storage'), findsOneWidget);
      expect(find.text('HealthBox data: 128 MB'), findsOneWidget);
      expect(find.text('Available: 14.8 GB'), findsOneWidget);
      expect(find.byKey(const Key('storage_usage_chart')), findsOneWidget);

      // Show warning if approaching limits
      expect(find.text('Storage usage is normal'), findsOneWidget);
    });

    testWidgets('manage sync permissions and privacy controls', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync privacy settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy_settings_button')));
      await tester.pumpAndSettle();

      // Step 1: Review sync permissions
      expect(find.text('Sync Privacy & Permissions'), findsOneWidget);
      
      expect(find.text('Current Permissions'), findsOneWidget);
      expect(find.text('✓ Access HealthBox folder'), findsOneWidget);
      expect(find.text('✓ Create and modify files'), findsOneWidget);
      expect(find.text('✓ Read file metadata'), findsOneWidget);
      expect(find.text('✗ Access to other files'), findsOneWidget);

      // Step 2: Configure data exclusions
      expect(find.text('Data Privacy Controls'), findsOneWidget);
      
      // Exclude sensitive record types
      await tester.tap(find.byKey(const Key('exclude_mental_health_toggle')));
      await tester.tap(find.byKey(const Key('exclude_reproductive_health_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Mental health records will not be synced'), findsOneWidget);
      expect(find.text('Reproductive health records will not be synced'), findsOneWidget);

      // Step 3: Configure sharing permissions
      expect(find.text('Family Sharing'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('enable_family_sharing_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Share data with family members'), findsOneWidget);
      
      // Configure family member permissions
      await tester.tap(find.byKey(const Key('family_permissions_button')));
      await tester.pumpAndSettle();

      expect(find.text('Family Member Permissions'), findsOneWidget);
      
      // Jane can view John's records
      await tester.tap(find.byKey(const Key('jane_view_john_toggle')));
      // But John cannot view Jane's records
      expect(find.byKey(const Key('john_view_jane_toggle')), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_family_permissions_button')));
      await tester.pumpAndSettle();

      // Step 4: Review audit log
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('sync_audit_log_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sync Audit Log'), findsOneWidget);
      expect(find.text('Track all sync activities'), findsOneWidget);

      // Should show detailed audit entries
      expect(find.text('Jan 15, 2:35 PM - Record uploaded (Prescription)'), findsOneWidget);
      expect(find.text('Jan 15, 2:34 PM - Record encrypted before upload'), findsOneWidget);
      expect(find.text('Jan 15, 2:30 PM - Sync initiated by user'), findsOneWidget);
      expect(find.text('Jan 15, 8:15 AM - Auto sync completed'), findsOneWidget);
    });

    testWidgets('disconnect and reconnect Google Drive sync', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Disconnect from Google Drive
      await tester.tap(find.byKey(const Key('disconnect_google_drive_button')));
      await tester.pumpAndSettle();

      expect(find.text('Disconnect Google Drive?'), findsOneWidget);
      expect(find.text('This will stop syncing but keep your cloud data'), findsOneWidget);

      // Show options for what to do with local data
      expect(find.text('Local data options:'), findsOneWidget);
      expect(find.byKey(const Key('keep_local_data_radio')), findsOneWidget);
      expect(find.byKey(const Key('delete_local_data_radio')), findsOneWidget);

      // Choose to keep local data
      await tester.tap(find.byKey(const Key('keep_local_data_radio')));
      await tester.tap(find.byKey(const Key('confirm_disconnect_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify disconnection
      expect(find.text('Google Drive Disconnected'), findsOneWidget);
      expect(find.text('Status: Not Connected'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Should show reconnect option
      expect(find.byKey(const Key('reconnect_google_drive_button')), findsOneWidget);
      expect(find.text('Your data remains safe locally'), findsOneWidget);

      // Step 3: Reconnect to Google Drive
      await tester.tap(find.byKey(const Key('reconnect_google_drive_button')));
      await tester.pumpAndSettle();

      expect(find.text('Reconnect to Google Drive'), findsOneWidget);
      expect(find.text('Restore sync with your existing cloud data'), findsOneWidget);

      await tester.tap(find.byKey(const Key('authorize_google_button')));
      await tester.pumpAndSettle();

      // Mock successful reconnection
      await tester.tap(find.byKey(const Key('mock_google_signin_success')));
      await tester.pumpAndSettle();

      // Step 4: Handle reconnection data merge
      expect(find.text('Reconnection Complete'), findsOneWidget);
      expect(find.text('Checking for data changes...'), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Data Sync Required'), findsOneWidget);
      expect(find.text('Local and cloud data will be merged'), findsOneWidget);
      expect(find.text('5 local changes to upload'), findsOneWidget);
      expect(find.text('2 cloud changes to download'), findsOneWidget);

      await tester.tap(find.byKey(const Key('start_merge_sync_button')));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 5: Verify reconnection success
      expect(find.text('Sync Restored'), findsOneWidget);
      expect(find.text('Status: Synced'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.text('All data synchronized successfully'), findsOneWidget);
    });

    testWidgets('handle sync with limited connectivity', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Simulate poor network conditions
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async {
          // Return limited connectivity
          return const StandardMethodCodec().encodeSuccessEnvelope('mobile');
        },
      );

      // Navigate to sync
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 2: Attempt sync with poor connectivity
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();

      // Should show connectivity warning
      expect(find.text('Limited Connectivity Detected'), findsOneWidget);
      expect(find.text('You are on mobile data with weak signal'), findsOneWidget);
      expect(find.text('Sync may be slow or fail'), findsOneWidget);

      // Show options for handling poor connectivity
      expect(find.byKey(const Key('sync_anyway_button')), findsOneWidget);
      expect(find.byKey(const Key('wait_for_wifi_button')), findsOneWidget);
      expect(find.byKey(const Key('sync_essential_only_button')), findsOneWidget);

      // Choose to sync essential data only
      await tester.tap(find.byKey(const Key('sync_essential_only_button')));
      await tester.pumpAndSettle();

      // Step 3: Perform limited sync
      expect(find.text('Syncing Essential Data...'), findsOneWidget);
      expect(find.text('Uploading critical records only'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Essential Sync Complete'), findsOneWidget);
      expect(find.text('✓ 3 critical records synced'), findsOneWidget);
      expect(find.text('12 non-essential records pending'), findsOneWidget);
      
      // Should schedule full sync for later
      expect(find.text('Full sync scheduled for WiFi connection'), findsOneWidget);

      // Step 4: Simulate WiFi restoration
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope('wifi');
        },
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should automatically start full sync
      expect(find.text('WiFi Connected - Starting Full Sync'), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Full Sync Complete'), findsOneWidget);
      expect(find.text('✓ All pending records synced'), findsOneWidget);
    });

    testWidgets('manage multiple device sync coordination', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to device management
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('manage_devices_button')));
      await tester.pumpAndSettle();

      // Step 1: View connected devices
      expect(find.text('Connected Devices'), findsOneWidget);
      expect(find.text('Devices using your HealthBox sync'), findsOneWidget);

      // Should show list of devices
      expect(find.text('iPhone 14 Pro (This device)'), findsOneWidget);
      expect(find.text('Last sync: Just now'), findsOneWidget);
      expect(find.byIcon(Icons.smartphone), findsOneWidget);

      expect(find.text('iPad Air'), findsOneWidget);
      expect(find.text('Last sync: 2 hours ago'), findsOneWidget);
      expect(find.byIcon(Icons.tablet), findsOneWidget);

      expect(find.text('Android Phone'), findsOneWidget);
      expect(find.text('Last sync: 1 week ago'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget); // Inactive warning

      // Step 2: Manage device permissions
      await tester.tap(find.byKey(const Key('device_options_android')));
      await tester.pumpAndSettle();

      expect(find.text('Device: Android Phone'), findsOneWidget);
      expect(find.text('Last active: 1 week ago'), findsOneWidget);
      expect(find.text('Status: Inactive'), findsOneWidget);

      // Options for inactive device
      expect(find.byKey(const Key('revoke_device_access_button')), findsOneWidget);
      expect(find.byKey(const Key('send_sync_notification_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('revoke_device_access_button')));
      await tester.pumpAndSettle();

      expect(find.text('Revoke Device Access?'), findsOneWidget);
      expect(find.text('This device will no longer be able to sync'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('confirm_revoke_button')));
      await tester.pumpAndSettle();

      expect(find.text('Device access revoked'), findsOneWidget);

      // Step 3: Handle sync conflicts between devices
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Simulate conflict from another device
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Device Sync Conflict'), findsOneWidget);
      expect(find.text('iPad Air modified the same record'), findsOneWidget);
      expect(find.text('Record: Lisinopril Prescription'), findsOneWidget);

      // Show device comparison
      expect(find.text('This Device (iPhone)'), findsOneWidget);
      expect(find.text('Modified: 30 minutes ago'), findsOneWidget);

      expect(find.text('iPad Air'), findsOneWidget);
      expect(find.text('Modified: 15 minutes ago'), findsOneWidget);

      // Choose to use the more recent version
      await tester.tap(find.byKey(const Key('use_ipad_version_button')));
      await tester.pumpAndSettle();

      expect(find.text('Conflict resolved'), findsOneWidget);
      expect(find.text('Using iPad version'), findsOneWidget);

      // Step 4: Verify device coordination
      expect(find.text('All devices synchronized'), findsOneWidget);
      expect(find.text('2 active devices'), findsOneWidget);
      expect(find.text('Last full sync: Just now'), findsOneWidget);
    });
  });
}