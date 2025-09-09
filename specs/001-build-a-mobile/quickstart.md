# HealthBox Quickstart Guide & Test Scenarios

## Overview
This document provides quickstart instructions for HealthBox and defines integration test scenarios that validate the complete user stories from the feature specification.

## Development Environment Setup

### Prerequisites
- Flutter 3.35+ with Dart 3.9+
- Android Studio / VS Code with Flutter extension
- iOS simulator (macOS) or Android emulator
- Git for version control

### Project Setup
```bash
# Clone repository
git clone <repository-url>
cd health_box

# Install dependencies
flutter pub get

# Generate code (Drift database, Riverpod providers)
dart run build_runner build

# Run tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Database Initialization
```dart
// Initialize encrypted database on first run
await StorageService.initialize(password: null); // No password initially
await ProfileService.createDefaultProfile(); // Optional setup profile
```

## Integration Test Scenarios

These scenarios validate the complete user stories from the feature specification and ensure all functional requirements are met.

### Scenario 1: First-Time User Setup
**Story**: New user opens app for the first time and creates their first family member profile
**Test File**: `integration_test/user_onboarding_test.dart`

```dart
testWidgets('First-time user can complete onboarding and create profile', (tester) async {
  // GIVEN: Fresh app installation
  await tester.pumpWidget(HealthBoxApp());
  
  // WHEN: User opens app for first time
  await tester.pumpAndSettle();
  
  // THEN: Onboarding screen is shown
  expect(find.text('Welcome to HealthBox'), findsOneWidget);
  
  // WHEN: User taps "Get Started"
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  
  // THEN: Profile creation form is shown
  expect(find.text('Create Your First Profile'), findsOneWidget);
  
  // WHEN: User fills in profile details
  await tester.enterText(find.byKey(Key('firstName')), 'John');
  await tester.enterText(find.byKey(Key('lastName')), 'Doe');
  await tester.tap(find.byKey(Key('dateOfBirth')));
  await tester.pumpAndSettle();
  // Select date: 1985-06-15
  await tester.tap(find.text('15'));
  await tester.tap(find.text('OK'));
  await tester.tap(find.byKey(Key('gender')));
  await tester.tap(find.text('Male'));
  
  // WHEN: User submits profile
  await tester.tap(find.text('Create Profile'));
  await tester.pumpAndSettle();
  
  // THEN: Main app screen is shown with profile
  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('Medical Records'), findsOneWidget);
});
```

### Scenario 2: Multiple Family Profile Management
**Story**: User with multiple family members can switch between profiles and manage independent data
**Test File**: `integration_test/family_profiles_test.dart`

```dart
testWidgets('User can manage multiple family member profiles', (tester) async {
  // GIVEN: App with one existing profile
  await setupTestApp(tester);
  
  // WHEN: User adds second family member
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(Key('firstName')), 'Jane');
  await tester.enterText(find.byKey(Key('lastName')), 'Doe');
  // ... fill other required fields
  await tester.tap(find.text('Create Profile'));
  await tester.pumpAndSettle();
  
  // THEN: Profile list shows both members
  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('Jane Doe'), findsOneWidget);
  
  // WHEN: User adds medication to John's profile
  await tester.tap(find.text('John Doe'));
  await tester.pumpAndSettle();
  await addMedication(tester, 'Aspirin', '81mg', 'Daily');
  
  // WHEN: User switches to Jane's profile
  await tester.tap(find.byIcon(Icons.person));
  await tester.tap(find.text('Jane Doe'));
  await tester.pumpAndSettle();
  
  // THEN: Jane's profile shows no medications
  expect(find.text('No medications added'), findsOneWidget);
  expect(find.text('Aspirin'), findsNothing);
  
  // WHEN: User switches back to John's profile
  await tester.tap(find.byIcon(Icons.person));
  await tester.tap(find.text('John Doe'));
  await tester.pumpAndSettle();
  
  // THEN: John's medication is still visible
  expect(find.text('Aspirin'), findsOneWidget);
});
```

### Scenario 3: Offline Functionality
**Story**: User can access and edit all data without internet connection
**Test File**: `integration_test/offline_functionality_test.dart`

```dart
testWidgets('App works fully offline', (tester) async {
  // GIVEN: App with existing data
  await setupTestAppWithData(tester);
  
  // WHEN: Internet connection is disabled
  await NetworkSimulator.disable();
  
  // THEN: App continues to function normally
  await tester.pumpAndSettle();
  expect(find.text('John Doe'), findsOneWidget);
  
  // WHEN: User adds new medication offline
  await tester.tap(find.byIcon(Icons.add));
  await tester.tap(find.text('Medication'));
  await tester.enterText(find.byKey(Key('medicationName')), 'Ibuprofen');
  await tester.enterText(find.byKey(Key('dosage')), '200mg');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  // THEN: Medication is saved locally
  expect(find.text('Ibuprofen'), findsOneWidget);
  
  // WHEN: User edits existing prescription
  await tester.tap(find.text('Aspirin'));
  await tester.enterText(find.byKey(Key('dosage')), '100mg'); // Change from 81mg
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  // THEN: Changes are persisted locally
  expect(find.text('100mg'), findsOneWidget);
  
  // WHEN: Internet is re-enabled
  await NetworkSimulator.enable();
  
  // THEN: App continues to show local data
  expect(find.text('Ibuprofen'), findsOneWidget);
  expect(find.text('100mg'), findsOneWidget);
});
```

### Scenario 4: Medication Reminders
**Story**: User sets up medication reminders and receives notifications
**Test File**: `integration_test/medication_reminders_test.dart`

```dart
testWidgets('Medication reminders work correctly', (tester) async {
  // GIVEN: App with medication
  await setupTestAppWithMedication(tester, 'Aspirin', '81mg', 'Daily');
  
  // WHEN: User sets up reminder
  await tester.tap(find.text('Aspirin'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Set Reminder'));
  await tester.tap(find.byKey(Key('time_8_00_AM')));
  await tester.tap(find.text('Daily'));
  await tester.tap(find.text('Save Reminder'));
  await tester.pumpAndSettle();
  
  // THEN: Reminder is created
  expect(find.text('Reminder set for 8:00 AM'), findsOneWidget);
  
  // WHEN: Scheduled time arrives (simulated)
  await NotificationSimulator.triggerScheduled('aspirin_reminder');
  await tester.pumpAndSettle();
  
  // THEN: Notification is shown
  expect(find.text('Time for Aspirin'), findsOneWidget);
  expect(find.text('Take 81mg as prescribed'), findsOneWidget);
  
  // WHEN: User marks medication as taken
  await tester.tap(find.text('Mark as Taken'));
  await tester.pumpAndSettle();
  
  // THEN: Next reminder is scheduled
  expect(find.text('Next reminder: Tomorrow 8:00 AM'), findsOneWidget);
});
```

### Scenario 5: Data Export and Sharing
**Story**: User exports medical data for healthcare provider
**Test File**: `integration_test/data_export_test.dart`

```dart
testWidgets('User can export medical data', (tester) async {
  // GIVEN: App with comprehensive medical data
  await setupTestAppWithCompleteData(tester);
  
  // WHEN: User accesses export function
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.tap(find.text('Export Data'));
  await tester.pumpAndSettle();
  
  // THEN: Export options are shown
  expect(find.text('Export Medical Records'), findsOneWidget);
  
  // WHEN: User selects PDF export
  await tester.tap(find.text('PDF Report'));
  await tester.tap(find.text('Include All Records'));
  await tester.tap(find.text('Generate Export'));
  await tester.pumpAndSettle();
  
  // THEN: Export is generated
  expect(find.text('Export completed'), findsOneWidget);
  
  // WHEN: User shares the export
  await tester.tap(find.text('Share'));
  await tester.pumpAndSettle();
  
  // THEN: System share dialog is shown
  expect(find.text('Share via'), findsOneWidget);
});
```

### Scenario 6: Google Drive Sync
**Story**: User syncs encrypted data with Google Drive
**Test File**: `integration_test/google_drive_sync_test.dart`

```dart
testWidgets('Google Drive sync works correctly', (tester) async {
  // GIVEN: App with local data
  await setupTestAppWithData(tester);
  
  // WHEN: User enables Google Drive sync
  await tester.tap(find.byIcon(Icons.settings));
  await tester.tap(find.text('Sync Settings'));
  await tester.tap(find.text('Connect Google Drive'));
  await tester.pumpAndSettle();
  
  // THEN: Google authentication starts
  await GoogleDriveSimulator.authenticate();
  await tester.pumpAndSettle();
  
  // WHEN: User starts manual sync
  await tester.tap(find.text('Sync Now'));
  await tester.pumpAndSettle();
  
  // THEN: Sync completes successfully
  expect(find.text('Sync completed'), findsOneWidget);
  expect(find.text('3 records uploaded'), findsOneWidget);
  
  // WHEN: User adds new data
  await addMedication(tester, 'Vitamins', '1 tablet', 'Daily');
  
  // WHEN: Auto-sync triggers
  await Future.delayed(Duration(seconds: 30));
  await tester.pumpAndSettle();
  
  // THEN: New data is synced
  expect(find.text('4 records synced'), findsOneWidget);
});
```

## Performance Test Scenarios

### Scenario 7: Large Dataset Performance
**Story**: App performs well with thousands of records
**Test File**: `integration_test/performance_test.dart`

```dart
testWidgets('App handles large datasets efficiently', (tester) async {
  // GIVEN: App with 1000+ medical records
  await setupLargeDataset(tester, recordCount: 1000);
  
  // WHEN: User opens profile
  final startTime = DateTime.now();
  await tester.tap(find.text('John Doe'));
  await tester.pumpAndSettle();
  final loadTime = DateTime.now().difference(startTime);
  
  // THEN: Profile loads within performance target
  expect(loadTime.inMilliseconds, lessThan(100));
  
  // WHEN: User scrolls through records
  final scrollStartTime = DateTime.now();
  await tester.drag(find.byType(ListView), Offset(0, -500));
  await tester.pumpAndSettle();
  final scrollTime = DateTime.now().difference(scrollStartTime);
  
  // THEN: Scrolling is smooth (60fps)
  expect(scrollTime.inMilliseconds, lessThan(50));
  
  // WHEN: User searches records
  final searchStartTime = DateTime.now();
  await tester.tap(find.byIcon(Icons.search));
  await tester.enterText(find.byKey(Key('searchField')), 'aspirin');
  await tester.pumpAndSettle();
  final searchTime = DateTime.now().difference(searchStartTime);
  
  // THEN: Search completes quickly
  expect(searchTime.inMilliseconds, lessThan(200));
});
```

## Manual Test Scenarios

### Edge Case Testing
1. **Device Storage Full**: Test behavior when device runs out of storage
2. **Database Corruption**: Verify integrity checks and recovery
3. **Google Drive Quota Exceeded**: Handle sync failures gracefully
4. **Airplane Mode**: Ensure offline notifications work
5. **App Backgrounding**: Test reminder notifications when app is closed

### Security Testing
1. **Database Encryption**: Verify SQLCipher encryption is active
2. **File System Permissions**: Ensure attachments are stored securely
3. **Memory Dumps**: Verify sensitive data is not leaked to memory
4. **Screen Recording Protection**: Test sensitive data protection

### Accessibility Testing
1. **Screen Reader**: Test with TalkBack/VoiceOver
2. **High Contrast**: Verify readability with system high contrast
3. **Large Text**: Test with maximum system font size
4. **Motor Accessibility**: Test with switch control

---

**Quickstart Status**: ✅ COMPLETE - Integration test scenarios defined
**Next Phase**: Task Generation Planning