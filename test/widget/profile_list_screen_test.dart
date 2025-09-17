// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// import 'package:health_box/features/profiles/screens/profile_list_screen.dart';
// import 'package:health_box/features/profiles/services/profile_service.dart';
// import 'package:health_box/data/models/family_member_profile.dart';

// import 'profile_list_screen_test.mocks.dart';

// @GenerateMocks([ProfileService])
// void main() {
//   late MockProfileService mockProfileService;

//   setUp(() {
//     mockProfileService = MockProfileService();
//   });

//   Widget createTestWidget({List<Override>? overrides}) {
//     return ProviderScope(
//       overrides: overrides ?? [],
//       child: MaterialApp(
//         home: ProfileListScreen(),
//       ),
//     );
//   }

//   group('ProfileListScreen Widget Tests', () {
//     final testProfiles = [
//       FamilyMemberProfile(
//         id: 1,
//         name: 'John Doe',
//         dateOfBirth: '1990-01-01',
//         gender: 'Male',
//         bloodType: 'O+',
//         phoneNumber: '+1234567890',
//         email: 'john.doe@example.com',
//         isActive: true,
//         createdAt: '2025-01-01T00:00:00.000Z',
//         updatedAt: '2025-01-01T00:00:00.000Z',
//       ),
//       FamilyMemberProfile(
//         id: 2,
//         name: 'Jane Doe',
//         dateOfBirth: '1995-05-15',
//         gender: 'Female',
//         bloodType: 'A+',
//         phoneNumber: '+1234567891',
//         email: 'jane.doe@example.com',
//         isActive: true,
//         createdAt: '2025-01-01T00:00:00.000Z',
//         updatedAt: '2025-01-01T00:00:00.000Z',
//       ),
//     ];

//     testWidgets('should display app bar with correct title', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(AppBar), findsOneWidget);
//       expect(find.text('Family Profiles'), findsOneWidget);
//     });

//     testWidgets('should display add profile floating action button', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(FloatingActionButton), findsOneWidget);
//       expect(find.byIcon(Icons.add), findsOneWidget);
//     });

//     testWidgets('should display list of profiles', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(ListView), findsOneWidget);
//       expect(find.text('John Doe'), findsOneWidget);
//       expect(find.text('Jane Doe'), findsOneWidget);
//     });

//     testWidgets('should display profile details in cards', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(Card), findsAtLeastNWidgets(2));
//       expect(find.text('Male'), findsOneWidget);
//       expect(find.text('Female'), findsOneWidget);
//       expect(find.text('O+'), findsOneWidget);
//       expect(find.text('A+'), findsOneWidget);
//     });

//     testWidgets('should display empty state when no profiles exist', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => []);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.text('No profiles found'), findsOneWidget);
//       expect(find.text('Add a family member to get started'), findsOneWidget);
//       expect(find.byIcon(Icons.people_outline), findsOneWidget);
//     });

//     testWidgets('should display loading indicator while loading', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles())
//           .thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => testProfiles));

//       // Act
//       await tester.pumpWidget(createTestWidget());

//       // Assert
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });

//     testWidgets('should navigate to add profile when FAB is tapped', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       await tester.tap(find.byType(FloatingActionButton));
//       await tester.pump();

//       // Note: In a real app, this would test navigation to ProfileFormScreen
//       // For now, we just verify the tap doesn't cause errors
//     });

//     testWidgets('should show profile menu when more icon is tapped', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Find and tap the more options button
//       await tester.tap(find.byIcon(Icons.more_vert).first);
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Edit'), findsOneWidget);
//       expect(find.text('Delete'), findsOneWidget);
//     });

//     testWidgets('should handle profile deletion', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);
//       when(mockProfileService.deleteProfile(1)).thenAnswer((_) async => true);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Open menu and tap delete
//       await tester.tap(find.byIcon(Icons.more_vert).first);
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();

//       // Confirm deletion in dialog
//       await tester.tap(find.text('Delete'));
//       await tester.pump();

//       // Assert
//       verify(mockProfileService.deleteProfile(1)).called(1);
//     });

//     testWidgets('should filter active profiles only', (WidgetTester tester) async {
//       // Arrange
//       final mixedProfiles = [
//         testProfiles[0],
//         testProfiles[1].copyWith(isActive: false),
//       ];
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => mixedProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert - should only show active profiles
//       expect(find.text('John Doe'), findsOneWidget);
//       expect(find.text('Jane Doe'), findsNothing); // Inactive profile should not show
//     });

//     testWidgets('should refresh profiles when pull to refresh is used', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Pull to refresh
//       await tester.drag(find.byType(ListView), Offset(0, 300));
//       await tester.pump();

//       // Assert that service is called again (in real implementation)
//       expect(find.byType(RefreshIndicator), findsOneWidget);
//     });

//     testWidgets('should search profiles when search is entered', (WidgetTester tester) async {
//       // Arrange
//       when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);
//       when(mockProfileService.searchProfiles('John')).thenAnswer((_) async => [testProfiles[0]]);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Tap search icon
//       await tester.tap(find.byIcon(Icons.search));
//       await tester.pump();

//       // Enter search text
//       await tester.enterText(find.byType(TextField), 'John');
//       await tester.pump();

//       // Assert
//       expect(find.text('John Doe'), findsOneWidget);
//       expect(find.text('Jane Doe'), findsNothing);
//     });

//     group('Error States', () {
//       testWidgets('should display error message when loading fails', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenThrow(Exception('Loading failed'));

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.text('Error loading profiles'), findsOneWidget);
//         expect(find.byIcon(Icons.error_outline), findsOneWidget);
//       });

//       testWidgets('should show retry button on error', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenThrow(Exception('Loading failed'));

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.text('Retry'), findsOneWidget);
//       });

//       testWidgets('should retry loading when retry button is tapped', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles())
//             .thenThrow(Exception('Loading failed'))
//             .thenAnswer((_) async => testProfiles);

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         await tester.tap(find.text('Retry'));
//         await tester.pump();

//         // Assert that loading is attempted again
//         expect(find.byType(CircularProgressIndicator), findsOneWidget);
//       });
//     });

//     group('Accessibility', () {
//       testWidgets('should have semantic labels for all interactive elements', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.bySemanticsLabel('Add new profile'), findsOneWidget);
//         expect(find.byType(Semantics), findsWidgets);
//       });

//       testWidgets('should support screen reader for profile cards', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Test that profile cards have proper semantics
//         final profileCards = find.byType(Card);
//         expect(profileCards, findsWidgets);

//         for (final card in tester.widgetList(profileCards)) {
//           expect(tester.getSemantics(find.byWidget(card)), isNotNull);
//         }
//       });
//     });

//     group('Responsive Design', () {
//       testWidgets('should display grid layout on tablets', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//         // Set tablet screen size
//         tester.binding.window.physicalSizeTestValue = Size(1024, 768);
//         tester.binding.window.devicePixelRatioTestValue = 1.0;

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert - on tablets, should use GridView instead of ListView
//         expect(find.byType(GridView), findsOneWidget);

//         // Cleanup
//         addTearDown(() {
//           tester.binding.window.clearPhysicalSizeTestValue();
//           tester.binding.window.clearDevicePixelRatioTestValue();
//         });
//       });

//       testWidgets('should display list layout on phones', (WidgetTester tester) async {
//         // Arrange
//         when(mockProfileService.getAllProfiles()).thenAnswer((_) async => testProfiles);

//         // Set phone screen size
//         tester.binding.window.physicalSizeTestValue = Size(375, 667);
//         tester.binding.window.devicePixelRatioTestValue = 2.0;

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert - on phones, should use ListView
//         expect(find.byType(ListView), findsOneWidget);

//         // Cleanup
//         addTearDown(() {
//           tester.binding.window.clearPhysicalSizeTestValue();
//           tester.binding.window.clearDevicePixelRatioTestValue();
//         });
//       });
//     });
//   });
// }
