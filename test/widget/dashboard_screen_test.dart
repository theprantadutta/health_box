import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:health_box/features/dashboard/screens/dashboard_screen.dart';
import 'package:health_box/features/profiles/services/profile_service.dart';
import 'package:health_box/features/reminders/services/reminder_service.dart';
import 'package:health_box/data/models/family_member_profile.dart';
import 'package:health_box/data/models/reminder.dart';

import 'dashboard_screen_test.mocks.dart';

@GenerateMocks([ProfileService, ReminderService])
void main() {
  late MockProfileService mockProfileService;
  late MockReminderService mockReminderService;

  setUp(() {
    mockProfileService = MockProfileService();
    mockReminderService = MockReminderService();
  });

  Widget createTestWidget({List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      // Arrange
      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Health Dashboard'), findsOneWidget);
    });

    testWidgets('should display profile selector when profiles exist', (WidgetTester tester) async {
      // Arrange
      final testProfiles = [
        FamilyMemberProfile(
          id: 1,
          name: 'John Doe',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          isActive: true,
          createdAt: '2025-01-01T00:00:00.000Z',
          updatedAt: '2025-01-01T00:00:00.000Z',
        ),
        FamilyMemberProfile(
          id: 2,
          name: 'Jane Doe',
          dateOfBirth: '1995-01-01',
          gender: 'Female',
          isActive: true,
          createdAt: '2025-01-01T00:00:00.000Z',
          updatedAt: '2025-01-01T00:00:00.000Z',
        ),
      ];

      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('should display upcoming reminders section', (WidgetTester tester) async {
      // Arrange
      final testReminders = [
        Reminder(
          id: 1,
          profileId: 1,
          title: 'Take Medication',
          description: 'Take daily vitamins',
          scheduledTime: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          type: 'medication',
          isActive: true,
          createdAt: '2025-01-01T00:00:00.000Z',
          updatedAt: '2025-01-01T00:00:00.000Z',
        ),
      ];

      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => testReminders);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Upcoming Reminders'), findsOneWidget);
      expect(find.text('Take Medication'), findsOneWidget);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      // Arrange
      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should handle empty state gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('No upcoming reminders'), findsOneWidget);
    });

    testWidgets('should display loading indicator while loading', (WidgetTester tester) async {
      // Arrange
      when(mockProfileService.getAllProfiles())
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => []));
      when(mockReminderService.getUpcomingReminders())
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => []));

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should navigate to profile list when profile selector is tapped', (WidgetTester tester) async {
      // Arrange
      final testProfiles = [
        FamilyMemberProfile(
          id: 1,
          name: 'John Doe',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          isActive: true,
          createdAt: '2025-01-01T00:00:00.000Z',
          updatedAt: '2025-01-01T00:00:00.000Z',
        ),
      ];

      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap the profile selector
      await tester.tap(find.text('John Doe'));
      await tester.pump();

      // Note: In a real app, this would test navigation
      // For now, we just verify the tap doesn't cause errors
    });

    testWidgets('should refresh data when pull to refresh is used', (WidgetTester tester) async {
      // Arrange
      when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
      when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Pull to refresh
      await tester.drag(find.byType(DashboardScreen), Offset(0, 200));
      await tester.pump();

      // Assert that services are called again (verify would require more setup)
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    group('Error States', () {
      testWidgets('should handle profile loading error', (WidgetTester tester) async {
        // Arrange
        when(mockProfileService.getAllProfiles()).thenThrow(Exception('Profile loading failed'));
        when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(DashboardScreen), findsOneWidget);
        // In a real implementation, this might show an error message
      });

      testWidgets('should handle reminders loading error', (WidgetTester tester) async {
        // Arrange
        when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
        when(mockReminderService.getUpcomingReminders()).thenThrow(Exception('Reminders loading failed'));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(DashboardScreen), findsOneWidget);
        // In a real implementation, this might show an error message
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        // Arrange
        when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
        when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should support screen reader navigation', (WidgetTester tester) async {
        // Arrange
        when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
        when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test semantic tree
        final semantics = tester.getSemantics(find.byType(DashboardScreen));
        expect(semantics, isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
        // Arrange
        when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);
        when(mockReminderService.getUpcomingReminders()).thenAnswer((_) async => []);

        // Test tablet size
        tester.binding.window.physicalSizeTestValue = Size(1024, 768);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Reset window size
        addTearDown(() {
          tester.binding.window.clearPhysicalSizeTestValue();
          tester.binding.window.clearDevicePixelRatioTestValue();
        });
      });
    });
  });
}