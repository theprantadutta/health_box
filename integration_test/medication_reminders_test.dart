import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for medication reminder functionality
/// 
/// User Story: "As a user taking multiple medications, I want to receive 
/// timely reminders so I never miss a dose and can track my medication 
/// adherence accurately."
/// 
/// Test Coverage:
/// - Creating medication reminders with various schedules
/// - Notification triggering and handling
/// - Snooze and dismiss functionality
/// - Recurring reminder management
/// - Medication tracking and adherence
/// - Reminder customization and preferences
/// - Integration with medication records
/// - Missed dose tracking and reporting
/// 
/// This test MUST fail until medication reminder system is implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Medication Reminders Integration Tests', () {
    testWidgets('create and manage daily medication reminders', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders section
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: Verify reminders screen
      expect(find.text('Medication Reminders'), findsOneWidget);
      expect(find.text('Never miss a dose'), findsOneWidget);
      expect(find.byKey(const Key('add_reminder_fab')), findsOneWidget);

      // Step 2: Create daily medication reminder
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      expect(find.text('New Medication Reminder'), findsOneWidget);
      
      // Link to existing medication or create new
      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add New Medication'));
      await tester.pumpAndSettle();

      // Create medication first
      await tester.enterText(
        find.byKey(const Key('medication_name_field')), 
        'Lisinopril'
      );
      await tester.enterText(
        find.byKey(const Key('dosage_field')), 
        '10mg'
      );
      await tester.enterText(
        find.byKey(const Key('frequency_field')), 
        'Once daily'
      );

      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      // Back to reminder setup
      expect(find.text('Lisinopril 10mg'), findsOneWidget);

      // Set reminder details
      await tester.enterText(
        find.byKey(const Key('reminder_title_field')), 
        'Morning Blood Pressure Medication'
      );
      await tester.enterText(
        find.byKey(const Key('reminder_description_field')), 
        'Take with water, preferably before breakfast'
      );

      // Set time - 8:00 AM
      await tester.tap(find.byKey(const Key('reminder_time_field')));
      await tester.pumpAndSettle();
      
      // Mock time picker selection
      await tester.tap(find.text('8'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('AM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Set frequency
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      // Configure advanced options
      await tester.tap(find.byKey(const Key('advanced_options_toggle')));
      await tester.pumpAndSettle();

      // Set snooze duration
      await tester.tap(find.byKey(const Key('snooze_duration_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15 minutes'));
      await tester.pumpAndSettle();

      // Enable sound
      await tester.tap(find.byKey(const Key('sound_enabled_toggle')));
      await tester.pumpAndSettle();

      // Save reminder
      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 3: Verify reminder was created
      expect(find.text('Reminder created successfully'), findsOneWidget);
      expect(find.text('Morning Blood Pressure Medication'), findsOneWidget);
      expect(find.text('8:00 AM daily'), findsOneWidget);
      expect(find.text('Lisinopril 10mg'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('create complex medication schedule with multiple doses', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: Create twice-daily medication reminder
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add New Medication'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')), 
        'Metformin'
      );
      await tester.enterText(
        find.byKey(const Key('dosage_field')), 
        '500mg'
      );

      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      // Set reminder title
      await tester.enterText(
        find.byKey(const Key('reminder_title_field')), 
        'Diabetes Medication'
      );

      // Set frequency to twice daily
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Multiple times daily'));
      await tester.pumpAndSettle();

      // Configure multiple time slots
      expect(find.text('Configure Time Slots'), findsOneWidget);
      
      // Morning dose
      await tester.tap(find.byKey(const Key('add_time_slot_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('AM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Evening dose
      await tester.tap(find.byKey(const Key('add_time_slot_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('PM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify time slots
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('8:00 PM'), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify complex schedule created
      expect(find.text('Diabetes Medication'), findsOneWidget);
      expect(find.text('8:00 AM, 8:00 PM daily'), findsOneWidget);
      expect(find.text('2 doses per day'), findsOneWidget);
    });

    testWidgets('handle medication reminder notifications', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Simulate reminder notification triggered
      // This would typically be triggered by the system at the scheduled time
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter_local_notifications',
        (message) async {
          // Mock notification triggered
          return null;
        },
      );

      // Simulate notification tap (app opened from notification)
      await tester.tap(find.byKey(const Key('notification_handler')));
      await tester.pumpAndSettle();

      // Step 2: Verify reminder alert displayed
      expect(find.text('Medication Reminder'), findsOneWidget);
      expect(find.text('Morning Blood Pressure Medication'), findsOneWidget);
      expect(find.text('Time to take Lisinopril 10mg'), findsOneWidget);
      expect(find.text('Take with water, preferably before breakfast'), findsOneWidget);

      // Should show action buttons
      expect(find.byKey(const Key('taken_button')), findsOneWidget);
      expect(find.byKey(const Key('snooze_button')), findsOneWidget);
      expect(find.byKey(const Key('skip_button')), findsOneWidget);

      // Step 3: Test "Mark as Taken" action
      await tester.tap(find.byKey(const Key('taken_button')));
      await tester.pumpAndSettle();

      expect(find.text('Medication marked as taken'), findsOneWidget);
      expect(find.text('Great job staying on track!'), findsOneWidget);

      // Should update adherence tracking
      expect(find.byKey(const Key('adherence_indicator')), findsOneWidget);
    });

    testWidgets('snooze and dismiss medication reminders', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate reminder notification
      await tester.tap(find.byKey(const Key('notification_handler')));
      await tester.pumpAndSettle();

      // Step 1: Test snooze functionality
      await tester.tap(find.byKey(const Key('snooze_button')));
      await tester.pumpAndSettle();

      expect(find.text('Snooze Reminder'), findsOneWidget);
      
      // Should show snooze options
      expect(find.text('5 minutes'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('1 hour'), findsOneWidget);

      // Select 15 minutes
      await tester.tap(find.text('15 minutes'));
      await tester.pumpAndSettle();

      expect(find.text('Reminder snoozed for 15 minutes'), findsOneWidget);
      
      // Should show snooze indicator
      expect(find.byIcon(Icons.snooze), findsOneWidget);
      expect(find.text('Snoozed until 8:15 AM'), findsOneWidget);

      // Step 2: Simulate snoozed reminder triggering again
      await Future.delayed(const Duration(seconds: 1)); // Simulate time passing
      await tester.tap(find.byKey(const Key('notification_handler')));
      await tester.pumpAndSettle();

      expect(find.text('Medication Reminder (Snoozed)'), findsOneWidget);

      // Step 3: Test skip/dismiss functionality
      await tester.tap(find.byKey(const Key('skip_button')));
      await tester.pumpAndSettle();

      expect(find.text('Skip This Dose?'), findsOneWidget);
      expect(find.text('This will be recorded as a missed dose'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('confirm_skip_button')));
      await tester.pumpAndSettle();

      expect(find.text('Dose marked as skipped'), findsOneWidget);
      
      // Should update missed dose tracking
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('medication adherence tracking and reporting', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: View adherence dashboard
      await tester.tap(find.byKey(const Key('adherence_tab')));
      await tester.pumpAndSettle();

      expect(find.text('Medication Adherence'), findsOneWidget);
      expect(find.text('Track your medication consistency'), findsOneWidget);

      // Should show overall adherence score
      expect(find.byKey(const Key('adherence_score')), findsOneWidget);
      expect(find.text('85%'), findsOneWidget); // Example adherence score
      expect(find.text('Good adherence'), findsOneWidget);

      // Step 2: View detailed adherence data
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.byKey(const Key('adherence_chart')), findsOneWidget);

      // Should show per-medication breakdown
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('6/7 doses taken'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.cancel), findsOneWidget); // Missed dose

      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('13/14 doses taken'), findsOneWidget);

      // Step 3: View missed doses details
      await tester.tap(find.text('View Missed Doses'));
      await tester.pumpAndSettle();

      expect(find.text('Missed Doses'), findsOneWidget);
      
      // Should show missed dose history
      expect(find.text('Yesterday, 8:00 AM'), findsOneWidget);
      expect(find.text('Lisinopril - Skipped'), findsOneWidget);
      expect(find.text('Reason: Forgot to take'), findsOneWidget);

      // Step 4: Generate adherence report
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('generate_report_button')));
      await tester.pumpAndSettle();

      expect(find.text('Adherence Report'), findsOneWidget);
      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('Export Report'), findsOneWidget);
    });

    testWidgets('customize reminder settings and preferences', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminder settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminder Settings'));
      await tester.pumpAndSettle();

      // Step 1: Configure global reminder preferences
      expect(find.text('Reminder Preferences'), findsOneWidget);
      
      // Default snooze duration
      expect(find.text('Default Snooze Duration'), findsOneWidget);
      await tester.tap(find.byKey(const Key('default_snooze_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10 minutes'));
      await tester.pumpAndSettle();

      // Notification sound
      expect(find.text('Notification Sound'), findsOneWidget);
      await tester.tap(find.byKey(const Key('notification_sound_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gentle Bell'));
      await tester.pumpAndSettle();

      // Vibration setting
      await tester.tap(find.byKey(const Key('vibration_toggle')));
      await tester.pumpAndSettle();

      // Step 2: Configure reminder window settings
      expect(find.text('Reminder Window'), findsOneWidget);
      expect(find.text('How early/late reminders can trigger'), findsOneWidget);
      
      await tester.tap(find.byKey(const Key('reminder_window_slider')));
      await tester.pumpAndSettle();

      // Step 3: Set quiet hours
      expect(find.text('Quiet Hours'), findsOneWidget);
      await tester.tap(find.byKey(const Key('quiet_hours_toggle')));
      await tester.pumpAndSettle();

      // Set start time
      await tester.tap(find.byKey(const Key('quiet_start_time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('PM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Set end time
      await tester.tap(find.byKey(const Key('quiet_end_time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('AM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Step 4: Save preferences
      await tester.tap(find.byKey(const Key('save_preferences_button')));
      await tester.pumpAndSettle();

      expect(find.text('Preferences saved'), findsOneWidget);
    });

    testWidgets('manage recurring medication schedules', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: Create weekly medication reminder
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      // Select existing medication
      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lisinopril 10mg'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reminder_title_field')), 
        'Weekly Vitamin D'
      );

      // Set to weekly frequency
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Select days of week
      expect(find.text('Select Days'), findsOneWidget);
      await tester.tap(find.text('Monday'));
      await tester.tap(find.text('Wednesday'));
      await tester.tap(find.text('Friday'));
      await tester.pumpAndSettle();

      // Set time
      await tester.tap(find.byKey(const Key('reminder_time_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify weekly schedule
      expect(find.text('Weekly Vitamin D'), findsOneWidget);
      expect(find.text('Mon, Wed, Fri at 8:00 AM'), findsOneWidget);

      // Step 3: Create monthly medication reminder
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add New Medication'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')), 
        'Birth Control'
      );
      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reminder_title_field')), 
        'Monthly Injection'
      );

      // Set to monthly frequency
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Set day of month
      expect(find.text('Day of Month'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('day_of_month_field')), '15');

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 4: Verify monthly schedule
      expect(find.text('Monthly Injection'), findsOneWidget);
      expect(find.text('15th of each month'), findsOneWidget);
    });

    testWidgets('medication inventory and refill reminders', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to medications
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medications'));
      await tester.pumpAndSettle();

      // Step 1: Set up medication inventory
      await tester.tap(find.text('Lisinopril'));
      await tester.pumpAndSettle();

      expect(find.text('Medication Details'), findsOneWidget);
      await tester.tap(find.byKey(const Key('edit_medication_button')));
      await tester.pumpAndSettle();

      // Add inventory information
      await tester.tap(find.byKey(const Key('inventory_section')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('current_pills_field')), 
        '25'
      );
      await tester.enterText(
        find.byKey(const Key('pills_per_dose_field')), 
        '1'
      );

      // Enable low stock alerts
      await tester.tap(find.byKey(const Key('low_stock_alert_toggle')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('low_stock_threshold_field')), 
        '7'
      );

      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify inventory tracking
      expect(find.text('25 pills remaining'), findsOneWidget);
      expect(find.text('~25 days supply'), findsOneWidget);
      expect(find.byKey(const Key('inventory_progress_bar')), findsOneWidget);

      // Step 3: Simulate low inventory trigger
      // This would happen after doses are taken and inventory decreases
      await tester.tap(find.byKey(const Key('simulate_low_stock_button')));
      await tester.pumpAndSettle();

      expect(find.text('Low Stock Alert'), findsOneWidget);
      expect(find.text('Lisinopril is running low'), findsOneWidget);
      expect(find.text('6 pills remaining'), findsOneWidget);
      expect(find.byKey(const Key('refill_reminder_button')), findsOneWidget);

      // Step 4: Set up refill reminder
      await tester.tap(find.byKey(const Key('refill_reminder_button')));
      await tester.pumpAndSettle();

      expect(find.text('Refill Reminder'), findsOneWidget);
      
      await tester.enterText(
        find.byKey(const Key('pharmacy_name_field')), 
        'CVS Pharmacy'
      );
      await tester.enterText(
        find.byKey(const Key('prescription_number_field')), 
        'RX123456'
      );

      await tester.tap(find.byKey(const Key('set_refill_reminder_button')));
      await tester.pumpAndSettle();

      expect(find.text('Refill reminder set'), findsOneWidget);
      expect(find.text('CVS Pharmacy - RX123456'), findsOneWidget);
    });

    testWidgets('emergency medication and PRN reminders', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Step 1: Create PRN (as needed) medication reminder
      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add New Medication'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')), 
        'Albuterol Inhaler'
      );
      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reminder_title_field')), 
        'Emergency Inhaler'
      );

      // Set as PRN medication
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('As Needed (PRN)'));
      await tester.pumpAndSettle();

      // Configure PRN settings
      expect(find.text('PRN Configuration'), findsOneWidget);
      
      await tester.enterText(
        find.byKey(const Key('max_doses_per_day_field')), 
        '4'
      );
      await tester.enterText(
        find.byKey(const Key('min_interval_minutes_field')), 
        '240'
      );

      // Set emergency contact notification
      await tester.tap(find.byKey(const Key('emergency_notification_toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Step 2: Verify PRN reminder setup
      expect(find.text('Emergency Inhaler'), findsOneWidget);
      expect(find.text('As needed, max 4/day'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);

      // Step 3: Test PRN medication usage tracking
      await tester.tap(find.text('Emergency Inhaler'));
      await tester.pumpAndSettle();

      expect(find.text('Take PRN Medication'), findsOneWidget);
      expect(find.byKey(const Key('take_now_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('take_now_button')));
      await tester.pumpAndSettle();

      // Should prompt for reason/symptoms
      expect(find.text('Why are you taking this?'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('symptoms_field')), 
        'Shortness of breath during exercise'
      );

      await tester.tap(find.byKey(const Key('confirm_taken_button')));
      await tester.pumpAndSettle();

      // Step 4: Verify usage tracking
      expect(find.text('Dose recorded'), findsOneWidget);
      expect(find.text('1/4 doses used today'), findsOneWidget);
      expect(find.text('Next dose available in 4 hours'), findsOneWidget);
    });

    testWidgets('medication interaction warnings', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add new medication
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medication'));
      await tester.pumpAndSettle();

      // Step 1: Add medication that may interact
      await tester.enterText(
        find.byKey(const Key('medication_name_field')), 
        'Warfarin'
      );
      await tester.enterText(
        find.byKey(const Key('dosage_field')), 
        '5mg'
      );

      await tester.tap(find.byKey(const Key('save_medication_button')));
      await tester.pumpAndSettle();

      // Step 2: System should check for interactions with existing medications
      expect(find.text('Potential Drug Interaction'), findsOneWidget);
      expect(find.text('Warfarin may interact with Lisinopril'), findsOneWidget);
      expect(find.text('Increased risk of hyperkalemia'), findsOneWidget);

      // Should show action options
      expect(find.byKey(const Key('proceed_anyway_button')), findsOneWidget);
      expect(find.byKey(const Key('consult_doctor_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_button')), findsOneWidget);

      // Step 3: Choose to proceed with warning
      await tester.tap(find.byKey(const Key('proceed_anyway_button')));
      await tester.pumpAndSettle();

      expect(find.text('Medication added with warning'), findsOneWidget);
      
      // Should show interaction warning on medication list
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Drug interaction warning'), findsOneWidget);

      // Step 4: Create reminder with interaction monitoring
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_reminder_fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('select_medication_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warfarin 5mg'));
      await tester.pumpAndSettle();

      // Should show interaction warning in reminder setup
      expect(find.text('⚠️ Drug Interaction Alert'), findsOneWidget);
      expect(find.text('Monitor for side effects'), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_reminder_button')));
      await tester.pumpAndSettle();

      // Reminder should include interaction monitoring
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Monitor interactions'), findsOneWidget);
    });
  });
}