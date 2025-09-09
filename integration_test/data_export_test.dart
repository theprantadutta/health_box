import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for data export and sharing functionality
/// 
/// User Story: "As a user, I want to export and share my medical data 
/// in various formats so I can provide comprehensive health information 
/// to healthcare providers and keep backup copies."
/// 
/// Test Coverage:
/// - Exporting medical records in multiple formats (PDF, CSV, JSON)
/// - Generating emergency medical cards
/// - Selective data export with filters
/// - Encrypted export with password protection
/// - Data import validation and processing
/// - Sharing exported files
/// - Emergency QR codes generation
/// - Export history tracking
/// 
/// This test MUST fail until export/sharing functionality is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Data Export and Sharing Integration Tests', () {
    testWidgets('export medical records to PDF format', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export section
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Verify export screen
      expect(find.text('Export Medical Data'), findsOneWidget);
      expect(find.text('Share your health information securely'), findsOneWidget);
      expect(find.byKey(const Key('export_options')), findsOneWidget);

      // Step 2: Configure PDF export
      await tester.tap(find.byKey(const Key('export_format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF Report'));
      await tester.pumpAndSettle();

      // Select profile to export
      await tester.tap(find.byKey(const Key('profile_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Configure what to include
      expect(find.text('What to Include'), findsOneWidget);
      expect(find.byKey(const Key('include_prescriptions_toggle')), findsOneWidget);
      expect(find.byKey(const Key('include_lab_reports_toggle')), findsOneWidget);
      expect(find.byKey(const Key('include_medications_toggle')), findsOneWidget);
      expect(find.byKey(const Key('include_allergies_toggle')), findsOneWidget);

      // Enable all record types
      await tester.tap(find.byKey(const Key('include_prescriptions_toggle')));
      await tester.tap(find.byKey(const Key('include_lab_reports_toggle')));
      await tester.tap(find.byKey(const Key('include_medications_toggle')));
      await tester.tap(find.byKey(const Key('include_allergies_toggle')));
      await tester.pumpAndSettle();

      // Set date range
      await tester.tap(find.byKey(const Key('date_range_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 12 months'));
      await tester.pumpAndSettle();

      // Include attachments
      await tester.tap(find.byKey(const Key('include_attachments_toggle')));
      await tester.pumpAndSettle();

      // Step 3: Generate PDF export
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      // Should show export progress
      expect(find.text('Generating PDF Export...'), findsOneWidget);
      expect(find.byKey(const Key('export_progress_indicator')), findsOneWidget);

      // Wait for export to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 4: Verify export completion
      expect(find.text('Export Complete'), findsOneWidget);
      expect(find.text('john_doe_medical_records.pdf'), findsOneWidget);
      expect(find.text('File size: 2.3 MB'), findsOneWidget);

      // Should show action buttons
      expect(find.byKey(const Key('view_export_button')), findsOneWidget);
      expect(find.byKey(const Key('share_export_button')), findsOneWidget);
      expect(find.byKey(const Key('save_to_device_button')), findsOneWidget);
    });

    testWidgets('export medical records to CSV format', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Configure CSV export
      await tester.tap(find.byKey(const Key('export_format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CSV Spreadsheet'));
      await tester.pumpAndSettle();

      expect(find.text('CSV Export Options'), findsOneWidget);
      expect(find.text('Data will be exported in spreadsheet format'), findsOneWidget);

      // Configure CSV-specific options
      await tester.tap(find.byKey(const Key('include_headers_toggle')));
      await tester.tap(find.byKey(const Key('separate_files_per_type_toggle')));
      await tester.pumpAndSettle();

      // Select multiple profiles for family export
      await tester.tap(find.byKey(const Key('export_all_profiles_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Export All Family Members'), findsOneWidget);
      expect(find.text('3 profiles will be included'), findsOneWidget);

      // Step 2: Generate CSV export
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Verify CSV export results
      expect(find.text('CSV Export Complete'), findsOneWidget);
      
      // Should create multiple CSV files
      expect(find.text('family_medical_records_prescriptions.csv'), findsOneWidget);
      expect(find.text('family_medical_records_lab_reports.csv'), findsOneWidget);
      expect(find.text('family_medical_records_medications.csv'), findsOneWidget);
      
      expect(find.text('3 files created'), findsOneWidget);
      expect(find.text('Total size: 1.8 MB'), findsOneWidget);
    });

    testWidgets('export medical records with encryption', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Configure encrypted export
      await tester.tap(find.byKey(const Key('export_format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encrypted ZIP'));
      await tester.pumpAndSettle();

      expect(find.text('Encrypted Export'), findsOneWidget);
      expect(find.text('Protect your data with a password'), findsOneWidget);

      // Set encryption password
      await tester.enterText(
        find.byKey(const Key('encryption_password_field')), 
        'SecurePassword123!'
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')), 
        'SecurePassword123!'
      );

      // Choose encryption strength
      await tester.tap(find.byKey(const Key('encryption_strength_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AES-256'));
      await tester.pumpAndSettle();

      // Include JSON format inside encrypted archive
      expect(find.text('Archive Contents'), findsOneWidget);
      await tester.tap(find.byKey(const Key('json_format_toggle')));
      await tester.tap(find.byKey(const Key('pdf_format_toggle')));
      await tester.pumpAndSettle();

      // Step 2: Generate encrypted export
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      expect(find.text('Encrypting data...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 3: Verify encrypted export
      expect(find.text('Encrypted Export Complete'), findsOneWidget);
      expect(find.text('john_doe_medical_records_encrypted.zip'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.text('AES-256 Encrypted'), findsOneWidget);

      // Should show sharing options with encryption notice
      await tester.tap(find.byKey(const Key('share_export_button')));
      await tester.pumpAndSettle();

      expect(find.text('Share Encrypted File'), findsOneWidget);
      expect(find.text('Remember to share the password separately'), findsOneWidget);
    });

    testWidgets('generate emergency medical card', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to emergency cards
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emergency Cards'));
      await tester.pumpAndSettle();

      // Step 1: Verify emergency cards screen
      expect(find.text('Emergency Medical Cards'), findsOneWidget);
      expect(find.text('Quick access to critical health information'), findsOneWidget);
      expect(find.byKey(const Key('create_card_button')), findsOneWidget);

      // Step 2: Create new emergency card
      await tester.tap(find.byKey(const Key('create_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Create Emergency Card'), findsOneWidget);

      // Select profile
      await tester.tap(find.byKey(const Key('profile_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Configure card contents
      expect(find.text('Critical Information'), findsOneWidget);
      
      // Add critical allergies
      await tester.tap(find.byKey(const Key('add_allergy_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('allergy_field')), 
        'Penicillin - Severe reaction'
      );
      await tester.tap(find.byKey(const Key('save_allergy_button')));
      await tester.pumpAndSettle();

      // Add current medications
      await tester.tap(find.byKey(const Key('add_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lisinopril 10mg'));
      await tester.pumpAndSettle();

      // Add medical conditions
      await tester.tap(find.byKey(const Key('add_condition_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('condition_field')), 
        'Hypertension'
      );
      await tester.tap(find.byKey(const Key('save_condition_button')));
      await tester.pumpAndSettle();

      // Add emergency contacts
      await tester.tap(find.byKey(const Key('add_emergency_contact_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('contact_name_field')), 
        'Jane Doe (Spouse)'
      );
      await tester.enterText(
        find.byKey(const Key('contact_phone_field')), 
        '+1-555-123-4567'
      );
      await tester.tap(find.byKey(const Key('save_contact_button')));
      await tester.pumpAndSettle();

      // Step 3: Choose card format
      expect(find.text('Card Format'), findsOneWidget);
      await tester.tap(find.byKey(const Key('format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Credit Card Size PDF'));
      await tester.pumpAndSettle();

      // Additional options
      await tester.tap(find.byKey(const Key('include_photo_toggle')));
      await tester.tap(find.byKey(const Key('include_qr_code_toggle')));
      await tester.pumpAndSettle();

      // Step 4: Generate emergency card
      await tester.tap(find.byKey(const Key('generate_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Generating Emergency Card...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 5: Verify card generation
      expect(find.text('Emergency Card Created'), findsOneWidget);
      expect(find.text('john_doe_emergency_card.pdf'), findsOneWidget);
      
      expect(find.byKey(const Key('preview_card_button')), findsOneWidget);
      expect(find.byKey(const Key('print_card_button')), findsOneWidget);
      expect(find.byKey(const Key('save_to_wallet_button')), findsOneWidget);

      // Step 6: Test card preview
      await tester.tap(find.byKey(const Key('preview_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Card Preview'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Allergies: Penicillin'), findsOneWidget);
      expect(find.text('Medications: Lisinopril 10mg'), findsOneWidget);
      expect(find.text('Emergency Contact: Jane Doe'), findsOneWidget);
      expect(find.byKey(const Key('qr_code_widget')), findsOneWidget);
    });

    testWidgets('generate QR code for emergency information', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to emergency cards
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emergency Cards'));
      await tester.pumpAndSettle();

      // Step 1: Generate QR code only
      await tester.tap(find.byKey(const Key('qr_code_tab')));
      await tester.pumpAndSettle();

      expect(find.text('Emergency QR Code'), findsOneWidget);
      expect(find.text('Scan for instant medical information'), findsOneWidget);

      await tester.tap(find.byKey(const Key('generate_qr_button')));
      await tester.pumpAndSettle();

      // Select profile
      await tester.tap(find.byKey(const Key('profile_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Configure QR content
      expect(find.text('QR Code Contents'), findsOneWidget);
      await tester.tap(find.byKey(const Key('include_allergies_toggle')));
      await tester.tap(find.byKey(const Key('include_medications_toggle')));
      await tester.tap(find.byKey(const Key('include_emergency_contacts_toggle')));
      await tester.pumpAndSettle();

      // Step 2: Generate QR code
      await tester.tap(find.byKey(const Key('create_qr_button')));
      await tester.pumpAndSettle();

      // Step 3: Verify QR code generation
      expect(find.text('QR Code Generated'), findsOneWidget);
      expect(find.byKey(const Key('qr_code_image')), findsOneWidget);
      
      // Should show sharing and saving options
      expect(find.byKey(const Key('save_qr_image_button')), findsOneWidget);
      expect(find.byKey(const Key('share_qr_code_button')), findsOneWidget);
      expect(find.byKey(const Key('print_qr_code_button')), findsOneWidget);

      // Step 4: Test QR code functionality
      await tester.tap(find.byKey(const Key('test_qr_scan_button')));
      await tester.pumpAndSettle();

      // Simulate QR code scan result
      expect(find.text('QR Scan Result'), findsOneWidget);
      expect(find.text('John Doe - Emergency Information'), findsOneWidget);
      expect(find.text('Critical Allergies: Penicillin'), findsOneWidget);
      expect(find.text('Current Medications: Lisinopril'), findsOneWidget);
      expect(find.text('Emergency Contact: Jane Doe'), findsOneWidget);
    });

    testWidgets('selective data export with filters', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Configure selective export
      await tester.tap(find.byKey(const Key('advanced_export_button')));
      await tester.pumpAndSettle();

      expect(find.text('Advanced Export Options'), findsOneWidget);

      // Step 2: Configure date range filter
      await tester.tap(find.byKey(const Key('date_filter_toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('start_date_field')));
      await tester.pumpAndSettle();
      // Select start date (would use actual date picker in real implementation)
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('end_date_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Step 3: Configure record type filters
      expect(find.text('Record Types'), findsOneWidget);
      await tester.tap(find.byKey(const Key('prescriptions_filter_toggle')));
      await tester.tap(find.byKey(const Key('lab_reports_filter_toggle')));
      await tester.pumpAndSettle();

      // Exclude medications and other types
      expect(find.text('Medications: Excluded'), findsOneWidget);
      expect(find.text('Prescriptions: Included'), findsOneWidget);

      // Step 4: Configure tag-based filtering
      await tester.tap(find.byKey(const Key('tag_filter_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Filter by Tags'), findsOneWidget);
      await tester.tap(find.byKey(const Key('tag_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Important'));
      await tester.tap(find.text('Doctor Visit'));
      await tester.pumpAndSettle();

      // Step 5: Configure privacy options
      expect(find.text('Privacy Options'), findsOneWidget);
      await tester.tap(find.byKey(const Key('anonymize_data_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Personal identifiers will be removed'), findsOneWidget);

      // Step 6: Generate filtered export
      await tester.tap(find.byKey(const Key('export_filtered_button')));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 7: Verify filtered export results
      expect(find.text('Filtered Export Complete'), findsOneWidget);
      expect(find.text('12 prescriptions exported'), findsOneWidget);
      expect(find.text('8 lab reports exported'), findsOneWidget);
      expect(find.text('Date range: Jan 1 - Dec 31, 2023'), findsOneWidget);
      expect(find.text('Tags: Important, Doctor Visit'), findsOneWidget);
      expect(find.text('Data anonymized'), findsOneWidget);
    });

    testWidgets('import medical data from exported file', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to import section
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('import_tab')));
      await tester.pumpAndSettle();

      // Step 1: Verify import screen
      expect(find.text('Import Medical Data'), findsOneWidget);
      expect(find.text('Import previously exported health records'), findsOneWidget);
      expect(find.byKey(const Key('select_file_button')), findsOneWidget);

      // Step 2: Select import file
      await tester.tap(find.byKey(const Key('select_file_button')));
      await tester.pumpAndSettle();

      // Mock file selection dialog
      expect(find.text('Select Import File'), findsOneWidget);
      await tester.tap(find.text('medical_export.json'));
      await tester.pumpAndSettle();

      // Step 3: Validate import file
      expect(find.text('Validating import file...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Import File Validation'), findsOneWidget);
      expect(find.text('✓ Valid HealthBox export file'), findsOneWidget);
      expect(find.text('✓ File format: JSON'), findsOneWidget);
      expect(find.text('✓ Contains 25 medical records'), findsOneWidget);
      expect(find.text('✓ Contains 2 family profiles'), findsOneWidget);
      expect(find.text('⚠ 3 records may be duplicates'), findsOneWidget);

      // Step 4: Configure import options
      expect(find.text('Import Options'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('skip_duplicates_toggle')));
      await tester.tap(find.byKey(const Key('merge_profiles_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Skip duplicate records'), findsOneWidget);
      expect(find.text('Merge with existing profiles'), findsOneWidget);

      // Step 5: Preview import
      await tester.tap(find.byKey(const Key('preview_import_button')));
      await tester.pumpAndSettle();

      expect(find.text('Import Preview'), findsOneWidget);
      expect(find.text('Records to import: 22'), findsOneWidget);
      expect(find.text('Duplicates to skip: 3'), findsOneWidget);
      expect(find.text('New profiles: 1'), findsOneWidget);
      expect(find.text('Profiles to merge: 1'), findsOneWidget);

      // Step 6: Execute import
      await tester.tap(find.byKey(const Key('confirm_import_button')));
      await tester.pumpAndSettle();

      expect(find.text('Importing data...'), findsOneWidget);
      expect(find.byKey(const Key('import_progress_bar')), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 7: Verify import completion
      expect(find.text('Import Complete'), findsOneWidget);
      expect(find.text('✓ 22 records imported successfully'), findsOneWidget);
      expect(find.text('✓ 1 new profile created'), findsOneWidget);
      expect(find.text('✓ 1 profile merged'), findsOneWidget);
      expect(find.text('⚠ 3 duplicates skipped'), findsOneWidget);

      // Should show option to view import log
      expect(find.byKey(const Key('view_import_log_button')), findsOneWidget);
    });

    testWidgets('share exported files via multiple channels', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create an export first
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 1: Access sharing options
      await tester.tap(find.byKey(const Key('share_export_button')));
      await tester.pumpAndSettle();

      expect(find.text('Share Medical Export'), findsOneWidget);
      expect(find.text('Choose how to share your health data'), findsOneWidget);

      // Step 2: Test email sharing
      await tester.tap(find.byKey(const Key('share_email_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email Medical Records'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('recipient_email_field')), 
        'doctor@clinic.com'
      );
      await tester.enterText(
        find.byKey(const Key('subject_field')), 
        'Medical Records for John Doe'
      );
      await tester.enterText(
        find.byKey(const Key('message_field')), 
        'Please find attached my medical records for review.'
      );

      await tester.tap(find.byKey(const Key('send_email_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email sent successfully'), findsOneWidget);

      // Step 3: Test cloud storage sharing
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('share_cloud_button')));
      await tester.pumpAndSettle();

      expect(find.text('Save to Cloud Storage'), findsOneWidget);
      
      // Should show available cloud services
      expect(find.text('Google Drive'), findsOneWidget);
      expect(find.text('Dropbox'), findsOneWidget);
      expect(find.text('iCloud'), findsOneWidget);

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(find.text('Saved to Google Drive'), findsOneWidget);
      expect(find.text('/HealthBox/Exports/'), findsOneWidget);

      // Step 4: Test secure link sharing
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('share_secure_link_button')));
      await tester.pumpAndSettle();

      expect(find.text('Create Secure Link'), findsOneWidget);
      expect(find.text('Generate a password-protected download link'), findsOneWidget);

      // Configure link options
      await tester.tap(find.byKey(const Key('expiry_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 days'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('download_limit_field')));
      await tester.enterText(find.byKey(const Key('download_limit_field')), '3');

      await tester.tap(find.byKey(const Key('create_link_button')));
      await tester.pumpAndSettle();

      expect(find.text('Secure Link Created'), findsOneWidget);
      expect(find.text('https://secure.healthbox.app/dl/abc123'), findsOneWidget);
      expect(find.text('Password: HealthBox2023!'), findsOneWidget);
      expect(find.text('Expires: 7 days'), findsOneWidget);
      expect(find.text('Download limit: 3'), findsOneWidget);

      expect(find.byKey(const Key('copy_link_button')), findsOneWidget);
      expect(find.byKey(const Key('share_link_button')), findsOneWidget);
    });

    testWidgets('view and manage export history', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export history
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('export_history_tab')));
      await tester.pumpAndSettle();

      // Step 1: Verify export history screen
      expect(find.text('Export History'), findsOneWidget);
      expect(find.text('View and manage your previous exports'), findsOneWidget);

      // Should show list of previous exports
      expect(find.byKey(const Key('export_history_list')), findsOneWidget);

      // Example export entries
      expect(find.text('john_doe_medical_records.pdf'), findsOneWidget);
      expect(find.text('PDF Export - 2.3 MB'), findsOneWidget);
      expect(find.text('January 15, 2024'), findsOneWidget);

      expect(find.text('family_medical_records_encrypted.zip'), findsOneWidget);
      expect(find.text('Encrypted ZIP - 4.1 MB'), findsOneWidget);
      expect(find.text('January 10, 2024'), findsOneWidget);

      // Step 2: Test export actions
      await tester.tap(find.byKey(const Key('export_options_0')));
      await tester.pumpAndSettle();

      expect(find.text('Export Options'), findsOneWidget);
      expect(find.byKey(const Key('re_download_button')), findsOneWidget);
      expect(find.byKey(const Key('share_again_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_export_button')), findsOneWidget);

      // Step 3: Re-download export
      await tester.tap(find.byKey(const Key('re_download_button')));
      await tester.pumpAndSettle();

      expect(find.text('Re-downloading export...'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Export downloaded'), findsOneWidget);

      // Step 4: Delete old export
      await tester.tap(find.byKey(const Key('export_options_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_export_button')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Export?'), findsOneWidget);
      expect(find.text('This will permanently remove the exported file'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Export deleted'), findsOneWidget);

      // Step 5: Export statistics
      expect(find.text('Export Statistics'), findsOneWidget);
      expect(find.text('Total exports: 12'), findsOneWidget);
      expect(find.text('Total data exported: 28.4 MB'), findsOneWidget);
      expect(find.text('Most recent: 3 days ago'), findsOneWidget);
    });

    testWidgets('handle large file export with progress tracking', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export with large dataset
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Configure large export
      await tester.tap(find.byKey(const Key('export_all_profiles_toggle')));
      await tester.tap(find.byKey(const Key('include_attachments_toggle')));
      await tester.tap(find.byKey(const Key('full_date_range_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Large export detected'), findsOneWidget);
      expect(find.text('Estimated size: ~15 MB'), findsOneWidget);
      expect(find.text('Estimated time: 2-3 minutes'), findsOneWidget);

      // Step 2: Start large export
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      // Step 3: Monitor export progress
      expect(find.text('Exporting Large Dataset...'), findsOneWidget);
      expect(find.byKey(const Key('detailed_progress_indicator')), findsOneWidget);
      
      // Should show detailed progress stages
      expect(find.text('Collecting records... (1/5)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Processing attachments... (2/5)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Generating PDF... (3/5)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Compressing files... (4/5)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Finalizing export... (5/5)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 4: Verify large export completion
      expect(find.text('Large Export Complete'), findsOneWidget);
      expect(find.text('all_family_medical_records.pdf'), findsOneWidget);
      expect(find.text('File size: 14.7 MB'), findsOneWidget);
      expect(find.text('3 profiles, 127 records, 45 attachments'), findsOneWidget);

      // Should warn about file size for sharing
      expect(find.text('⚠ Large file - consider using cloud sharing'), findsOneWidget);
    });
  });
}