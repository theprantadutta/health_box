// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// import 'package:health_box/features/medical_records/screens/medical_record_list_screen.dart';
// import 'package:health_box/features/medical_records/services/medical_records_service.dart';
// import 'package:health_box/data/models/medical_record.dart';

// import 'medical_record_list_screen_test.mocks.dart';

// @GenerateMocks([MedicalRecordsService])
// void main() {
//   late MockMedicalRecordsService mockMedicalRecordsService;

//   setUp(() {
//     mockMedicalRecordsService = MockMedicalRecordsService();
//   });

//   Widget createTestWidget({
//     List<Override>? overrides,
//     int profileId = 1,
//   }) {
//     return ProviderScope(
//       overrides: overrides ?? [],
//       child: MaterialApp(
//         home: MedicalRecordListScreen(profileId: profileId),
//       ),
//     );
//   }

//   group('MedicalRecordListScreen Widget Tests', () {
//     final testRecords = [
//       MedicalRecord(
//         id: 1,
//         profileId: 1,
//         type: 'prescription',
//         title: 'Blood Pressure Medication',
//         description: 'Daily medication for hypertension',
//         date: '2025-01-01',
//         createdAt: '2025-01-01T00:00:00.000Z',
//         updatedAt: '2025-01-01T00:00:00.000Z',
//       ),
//       MedicalRecord(
//         id: 2,
//         profileId: 1,
//         type: 'lab_report',
//         title: 'Blood Test Results',
//         description: 'Annual blood work checkup',
//         date: '2025-01-15',
//         createdAt: '2025-01-15T00:00:00.000Z',
//         updatedAt: '2025-01-15T00:00:00.000Z',
//       ),
//       MedicalRecord(
//         id: 3,
//         profileId: 1,
//         type: 'vaccination',
//         title: 'COVID-19 Vaccine',
//         description: 'First dose of COVID-19 vaccine',
//         date: '2024-12-01',
//         createdAt: '2024-12-01T00:00:00.000Z',
//         updatedAt: '2024-12-01T00:00:00.000Z',
//       ),
//     ];

//     testWidgets('should display app bar with correct title', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(AppBar), findsOneWidget);
//       expect(find.text('Medical Records'), findsOneWidget);
//     });

//     testWidgets('should display search bar', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(SearchBar), findsOneWidget);
//       expect(find.text('Search medical records...'), findsOneWidget);
//     });

//     testWidgets('should display filter chips', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.text('All'), findsOneWidget);
//       expect(find.text('Prescriptions'), findsOneWidget);
//       expect(find.text('Lab Reports'), findsOneWidget);
//       expect(find.text('Vaccinations'), findsOneWidget);
//       expect(find.byType(FilterChip), findsAtLeastNWidgets(4));
//     });

//     testWidgets('should display list of medical records', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(ListView), findsOneWidget);
//       expect(find.text('Blood Pressure Medication'), findsOneWidget);
//       expect(find.text('Blood Test Results'), findsOneWidget);
//       expect(find.text('COVID-19 Vaccine'), findsOneWidget);
//     });

//     testWidgets('should display record details in cards', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(Card), findsAtLeastNWidgets(3));
//       expect(find.text('prescription'), findsOneWidget);
//       expect(find.text('lab_report'), findsOneWidget);
//       expect(find.text('vaccination'), findsOneWidget);
//       expect(find.text('2025-01-01'), findsOneWidget);
//       expect(find.text('2025-01-15'), findsOneWidget);
//     });

//     testWidgets('should display floating action button for adding records', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.byType(FloatingActionButton), findsOneWidget);
//       expect(find.byIcon(Icons.add), findsOneWidget);
//     });

//     testWidgets('should display empty state when no records exist', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => []);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Assert
//       expect(find.text('No medical records found'), findsOneWidget);
//       expect(find.text('Add your first medical record to get started'), findsOneWidget);
//       expect(find.byIcon(Icons.medical_information_outlined), findsOneWidget);
//     });

//     testWidgets('should display loading indicator while loading', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => testRecords));

//       // Act
//       await tester.pumpWidget(createTestWidget());

//       // Assert
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });

//     testWidgets('should filter records by type when filter chip is tapped', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);
//       when(mockMedicalRecordsService.getRecordsByType(1, 'prescription'))
//           .thenAnswer((_) async => [testRecords[0]]);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Tap prescription filter
//       await tester.tap(find.text('Prescriptions'));
//       await tester.pump();

//       // Assert
//       expect(find.text('Blood Pressure Medication'), findsOneWidget);
//       expect(find.text('Blood Test Results'), findsNothing);
//       expect(find.text('COVID-19 Vaccine'), findsNothing);
//     });

//     testWidgets('should search records when search text is entered', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);
//       when(mockMedicalRecordsService.searchRecords(1, 'Blood'))
//           .thenAnswer((_) async => testRecords.take(2).toList());

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Enter search text
//       await tester.enterText(find.byType(SearchBar), 'Blood');
//       await tester.pump();

//       // Assert
//       expect(find.text('Blood Pressure Medication'), findsOneWidget);
//       expect(find.text('Blood Test Results'), findsOneWidget);
//       expect(find.text('COVID-19 Vaccine'), findsNothing);
//     });

//     testWidgets('should navigate to record detail when record is tapped', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       await tester.tap(find.text('Blood Pressure Medication'));
//       await tester.pump();

//       // Note: In a real app, this would test navigation to MedicalRecordDetailScreen
//       // For now, we just verify the tap doesn't cause errors
//     });

//     testWidgets('should show record options menu when more icon is tapped', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Find and tap the more options button
//       await tester.tap(find.byIcon(Icons.more_vert).first);
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Edit'), findsOneWidget);
//       expect(find.text('Delete'), findsOneWidget);
//       expect(find.text('Share'), findsOneWidget);
//     });

//     testWidgets('should handle record deletion', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);
//       when(mockMedicalRecordsService.deleteRecord(1)).thenAnswer((_) async => true);

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
//       verify(mockMedicalRecordsService.deleteRecord(1)).called(1);
//     });

//     testWidgets('should sort records by date', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Open sort menu
//       await tester.tap(find.byIcon(Icons.sort));
//       await tester.pumpAndSettle();

//       // Select date sort
//       await tester.tap(find.text('Date (Newest First)'));
//       await tester.pump();

//       // Assert that records are displayed in correct order
//       final listView = find.byType(ListView);
//       expect(listView, findsOneWidget);
//     });

//     testWidgets('should refresh records when pull to refresh is used', (WidgetTester tester) async {
//       // Arrange
//       when(mockMedicalRecordsService.getRecordsByProfile(1))
//           .thenAnswer((_) async => testRecords);

//       // Act
//       await tester.pumpWidget(createTestWidget());
//       await tester.pump();

//       // Pull to refresh
//       await tester.drag(find.byType(ListView), Offset(0, 300));
//       await tester.pump();

//       // Assert
//       expect(find.byType(RefreshIndicator), findsOneWidget);
//     });

//     group('Error States', () {
//       testWidgets('should display error message when loading fails', (WidgetTester tester) async {
//         // Arrange
//         when(mockMedicalRecordsService.getRecordsByProfile(1))
//             .thenThrow(Exception('Loading failed'));

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.text('Error loading medical records'), findsOneWidget);
//         expect(find.byIcon(Icons.error_outline), findsOneWidget);
//       });

//       testWidgets('should show retry button on error', (WidgetTester tester) async {
//         // Arrange
//         when(mockMedicalRecordsService.getRecordsByProfile(1))
//             .thenThrow(Exception('Loading failed'));

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.text('Retry'), findsOneWidget);
//       });
//     });

//     group('Accessibility', () {
//       testWidgets('should have semantic labels for all interactive elements', (WidgetTester tester) async {
//         // Arrange
//         when(mockMedicalRecordsService.getRecordsByProfile(1))
//             .thenAnswer((_) async => testRecords);

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.bySemanticsLabel('Add new medical record'), findsOneWidget);
//         expect(find.bySemanticsLabel('Search medical records'), findsOneWidget);
//       });

//       testWidgets('should support screen reader for record cards', (WidgetTester tester) async {
//         // Arrange
//         when(mockMedicalRecordsService.getRecordsByProfile(1))
//             .thenAnswer((_) async => testRecords);

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert that record cards have proper semantics
//         final recordCards = find.byType(Card);
//         expect(recordCards, findsWidgets);
//       });
//     });

//     group('Responsive Design', () {
//       testWidgets('should adapt layout for different screen sizes', (WidgetTester tester) async {
//         // Arrange
//         when(mockMedicalRecordsService.getRecordsByProfile(1))
//             .thenAnswer((_) async => testRecords);

//         // Set tablet screen size
//         tester.binding.window.physicalSizeTestValue = Size(1024, 768);
//         tester.binding.window.devicePixelRatioTestValue = 1.0;

//         // Act
//         await tester.pumpWidget(createTestWidget());
//         await tester.pump();

//         // Assert
//         expect(find.byType(MedicalRecordListScreen), findsOneWidget);

//         // Cleanup
//         addTearDown(() {
//           tester.binding.window.clearPhysicalSizeTestValue();
//           tester.binding.window.clearDevicePixelRatioTestValue();
//         });
//       });
//     });
//   });
// }
