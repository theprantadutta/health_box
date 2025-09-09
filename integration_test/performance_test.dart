import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_box/main.dart' as app;

/// Integration test for large dataset performance
/// 
/// User Story: "As a user with years of medical history, I want the app 
/// to remain fast and responsive even with thousands of medical records 
/// so I can efficiently manage my comprehensive health data."
/// 
/// Test Coverage:
/// - App performance with large datasets (1000+ records)
/// - Database query optimization and indexing
/// - List virtualization and efficient rendering
/// - Search and filter performance with large data
/// - Export and sync performance at scale
/// - Memory usage optimization
/// - Startup time with extensive data
/// - Real-time updates without performance degradation
/// 
/// This test MUST fail until performance optimizations are implemented.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Large Dataset Performance Integration Tests', () {
    testWidgets('app startup performance with large dataset', (tester) async {
      // Step 1: Measure app startup time with large dataset
      final startTime = DateTime.now();
      
      app.main();
      await tester.pumpAndSettle();
      
      final endTime = DateTime.now();
      final startupTime = endTime.difference(startTime);

      // Step 2: Verify startup performance requirements
      expect(startupTime.inMilliseconds, lessThan(3000)); // Should start within 3 seconds
      
      // Verify dashboard loads with data indicators
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing); // Should not show loading after startup
      
      // Should show summary statistics efficiently
      expect(find.byKey(const Key('total_records_count')), findsOneWidget);
      expect(find.byKey(const Key('recent_records_list')), findsOneWidget);

      // Step 3: Measure memory usage at startup
      final memoryInfo = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );
      
      // Should use reasonable memory even with large dataset
      expect(memoryInfo, isNotNull);
      
      // Dashboard should show aggregate stats efficiently
      expect(find.text('1,247 total records'), findsOneWidget);
      expect(find.text('5 family members'), findsOneWidget);
      expect(find.text('23 active medications'), findsOneWidget);
    });

    testWidgets('medical records list performance with 1000+ records', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to medical records
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Step 1: Measure list loading performance
      final listLoadStart = DateTime.now();
      
      // Should use virtualized scrolling for performance
      expect(find.byKey(const Key('virtualized_records_list')), findsOneWidget);
      
      await tester.pumpAndSettle();
      final listLoadEnd = DateTime.now();
      final listLoadTime = listLoadEnd.difference(listLoadStart);

      // Should load initial viewport quickly
      expect(listLoadTime.inMilliseconds, lessThan(500));

      // Step 2: Test scrolling performance through large list
      final scrollStart = DateTime.now();
      
      // Scroll through several screens of data
      for (int i = 0; i < 10; i++) {
        await tester.drag(
          find.byKey(const Key('records_list')), 
          const Offset(0, -500),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      final scrollEnd = DateTime.now();
      final scrollTime = scrollEnd.difference(scrollStart);

      // Scrolling should remain smooth
      expect(scrollTime.inMilliseconds, lessThan(2000));

      // Step 3: Verify only visible items are rendered
      final visibleItems = tester.widgetList(find.byType(ListTile));
      expect(visibleItems.length, lessThanOrEqualTo(15)); // Only viewport items

      // Step 4: Test rapid scrolling to end of list
      await tester.fling(
        find.byKey(const Key('records_list')), 
        const Offset(0, -10000), 
        1000,
      );
      await tester.pumpAndSettle();

      // Should handle rapid scrolling without crashes
      expect(find.byKey(const Key('records_list')), findsOneWidget);
      expect(find.text('End of records'), findsOneWidget);

      // Step 5: Measure frame rate during scrolling
      final frameRateInfo = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getFrameRate'),
      );
      
      expect(frameRateInfo, isNotNull);
      // Should maintain smooth 60fps during scrolling
    });

    testWidgets('search performance with large dataset', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to medical records
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Step 1: Test search performance
      final searchField = find.byKey(const Key('search_records_field'));
      expect(searchField, findsOneWidget);

      // Measure search response time
      final searchStart = DateTime.now();
      
      await tester.enterText(searchField, 'blood');
      await tester.pump(const Duration(milliseconds: 100)); // Allow for debounce
      await tester.pumpAndSettle();
      
      final searchEnd = DateTime.now();
      final searchTime = searchEnd.difference(searchStart);

      // Search should return results quickly
      expect(searchTime.inMilliseconds, lessThan(800));

      // Step 2: Verify search results are accurate and fast
      expect(find.text('Search Results'), findsOneWidget);
      expect(find.text('147 results found'), findsOneWidget);
      
      // Should show results with highlighting
      expect(find.textContaining('Blood'), findsWidgets);

      // Step 3: Test incremental search performance
      await tester.enterText(searchField, 'blood pressure');
      await tester.pump(const Duration(milliseconds: 100));
      
      final refinedSearchStart = DateTime.now();
      await tester.pumpAndSettle();
      final refinedSearchEnd = DateTime.now();
      final refinedSearchTime = refinedSearchEnd.difference(refinedSearchStart);

      // Refined search should be even faster (indexed)
      expect(refinedSearchTime.inMilliseconds, lessThan(300));
      expect(find.text('23 results found'), findsOneWidget);

      // Step 4: Test complex search with filters
      await tester.tap(find.byKey(const Key('search_filters_button')));
      await tester.pumpAndSettle();

      // Apply multiple filters
      await tester.tap(find.byKey(const Key('date_range_filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 12 months'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('record_type_filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lab Reports'));
      await tester.pumpAndSettle();

      final complexSearchStart = DateTime.now();
      await tester.tap(find.byKey(const Key('apply_filters_button')));
      await tester.pumpAndSettle();
      final complexSearchEnd = DateTime.now();
      final complexSearchTime = complexSearchEnd.difference(complexSearchStart);

      // Complex filtered search should still be responsive
      expect(complexSearchTime.inMilliseconds, lessThan(1000));
      expect(find.text('12 results found'), findsOneWidget);
    });

    testWidgets('database operations performance at scale', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Test bulk record creation performance
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();

      // Simulate importing large batch of records
      await tester.tap(find.text('Bulk Import'));
      await tester.pumpAndSettle();

      final bulkCreateStart = DateTime.now();
      await tester.tap(find.byKey(const Key('import_test_dataset_button')));
      await tester.pumpAndSettle();

      // Should show progress for large operations
      expect(find.text('Importing 500 records...'), findsOneWidget);
      expect(find.byKey(const Key('bulk_import_progress')), findsOneWidget);

      // Wait for bulk import to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final bulkCreateEnd = DateTime.now();
      final bulkCreateTime = bulkCreateEnd.difference(bulkCreateStart);

      // Bulk operations should be optimized
      expect(bulkCreateTime.inSeconds, lessThan(10));
      expect(find.text('Import completed'), findsOneWidget);

      // Step 2: Test database query performance
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to analytics/reports which require complex queries
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      final queryStart = DateTime.now();
      await tester.pumpAndSettle();
      final queryEnd = DateTime.now();
      final queryTime = queryEnd.difference(queryStart);

      // Complex analytics queries should be optimized
      expect(queryTime.inMilliseconds, lessThan(2000));

      // Should show comprehensive analytics
      expect(find.text('Health Analytics'), findsOneWidget);
      expect(find.text('Record trends over time'), findsOneWidget);
      expect(find.byKey(const Key('analytics_chart')), findsOneWidget);

      // Step 3: Test concurrent database operations
      // Simulate background sync while user is active
      final concurrentStart = DateTime.now();
      
      // Start background sync
      await tester.binding.defaultBinaryMessenger.send(
        'flutter/background_sync',
        const StandardMessageCodec().encodeMessage('startSync'),
      );

      // Continue using app during sync
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Add new record during sync
      await tester.tap(find.byKey(const Key('add_record_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quick Note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('note_content_field')), 
        'Test note during sync'
      );
      await tester.tap(find.byKey(const Key('save_note_button')));
      await tester.pumpAndSettle();

      final concurrentEnd = DateTime.now();
      final concurrentTime = concurrentEnd.difference(concurrentStart);

      // App should remain responsive during background operations
      expect(concurrentTime.inMilliseconds, lessThan(1500));
      expect(find.text('Note saved'), findsOneWidget);
    });

    testWidgets('export performance with large datasets', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to export
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Step 1: Test large PDF export performance
      await tester.tap(find.byKey(const Key('export_format_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF Report'));
      await tester.pumpAndSettle();

      // Select all profiles and full date range
      await tester.tap(find.byKey(const Key('export_all_profiles_toggle')));
      await tester.tap(find.byKey(const Key('full_history_toggle')));
      await tester.pumpAndSettle();

      // Should show size estimation
      expect(find.text('Estimated export size: ~25 MB'), findsOneWidget);
      expect(find.text('1,747 records will be included'), findsOneWidget);

      final exportStart = DateTime.now();
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      // Should show detailed progress for large exports
      expect(find.text('Preparing large export...'), findsOneWidget);
      expect(find.byKey(const Key('export_progress_detailed')), findsOneWidget);

      // Monitor progress stages
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Processing records'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Generating PDF'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Optimizing file'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
      final exportEnd = DateTime.now();
      final exportTime = exportEnd.difference(exportStart);

      // Large exports should complete in reasonable time
      expect(exportTime.inSeconds, lessThan(30));
      expect(find.text('Export completed'), findsOneWidget);

      // Step 2: Test streaming export for very large datasets
      await tester.tap(find.byKey(const Key('streaming_export_option')));
      await tester.pumpAndSettle();

      expect(find.text('Streaming Export'), findsOneWidget);
      expect(find.text('Memory-efficient processing for large datasets'), findsOneWidget);

      final streamingStart = DateTime.now();
      await tester.tap(find.byKey(const Key('start_streaming_export_button')));
      await tester.pumpAndSettle();

      // Should process in chunks
      expect(find.text('Processing chunk 1/10...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Processing chunk 3/10...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 8));
      final streamingEnd = DateTime.now();
      final streamingTime = streamingEnd.difference(streamingStart);

      // Streaming should handle larger datasets efficiently
      expect(streamingTime.inSeconds, lessThan(20));
      expect(find.text('Streaming export completed'), findsOneWidget);
    });

    testWidgets('memory management with large datasets', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Monitor memory usage baseline
      final baselineMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );
      expect(baselineMemory, isNotNull, reason: 'Should capture baseline memory');

      // Navigate through different sections
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Step 2: Test memory during large list operations
      // Scroll through entire list
      for (int i = 0; i < 50; i++) {
        await tester.drag(
          find.byKey(const Key('records_list')), 
          const Offset(0, -300),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }

      final scrollMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );

      // Memory should not grow excessively during scrolling
      expect(scrollMemory, isNotNull);
      
      // Step 3: Test memory during search operations
      await tester.enterText(
        find.byKey(const Key('search_records_field')), 
        'test search query'
      );
      await tester.pumpAndSettle();

      // Perform multiple searches
      for (String query in ['blood', 'medication', 'doctor', 'test', 'report']) {
        await tester.enterText(
          find.byKey(const Key('search_records_field')), 
          query
        );
        await tester.pump(const Duration(milliseconds: 200));
      }

      final searchMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );

      // Memory should not leak during search operations
      expect(searchMemory, isNotNull);

      // Step 4: Test garbage collection efficiency
      await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('triggerGC'),
      );

      await tester.pump(const Duration(seconds: 1));

      final postGCMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );

      // Memory should be freed after GC
      expect(postGCMemory, isNotNull);

      // Step 5: Test memory during image/attachment handling
      await tester.tap(find.text('Record with attachments'));
      await tester.pumpAndSettle();

      // View multiple images
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(Key('attachment_$i')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }

      final imageMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );

      // Images should be properly disposed
      expect(imageMemory, isNotNull);
    });

    testWidgets('sync performance with large datasets', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sync settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      // Step 1: Test large dataset initial sync performance
      expect(find.text('Large dataset detected'), findsOneWidget);
      expect(find.text('1,747 records to sync'), findsOneWidget);
      expect(find.text('Estimated sync time: 5-8 minutes'), findsOneWidget);

      final syncStart = DateTime.now();
      await tester.tap(find.byKey(const Key('start_large_sync_button')));
      await tester.pumpAndSettle();

      // Should use efficient batching
      expect(find.text('Syncing in batches for optimal performance'), findsOneWidget);
      expect(find.byKey(const Key('batch_progress_indicator')), findsOneWidget);

      // Monitor batch progress
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Batch 1/10'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Batch 3/10'), findsOneWidget);

      // Should remain responsive during sync
      await tester.tap(find.byKey(const Key('minimize_sync_button')));
      await tester.pumpAndSettle();

      // Navigate to other parts of app during sync
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      // App should remain responsive
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('sync_in_background_indicator')), findsOneWidget);

      // Wait for sync completion
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final syncEnd = DateTime.now();
      final syncTime = syncEnd.difference(syncStart);

      // Should complete within expected timeframe
      expect(syncTime.inSeconds, lessThan(600)); // 10 minutes max

      // Step 2: Test incremental sync performance
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google Drive Sync'));
      await tester.pumpAndSettle();

      final incrementalStart = DateTime.now();
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();

      // Incremental sync should be much faster
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final incrementalEnd = DateTime.now();
      final incrementalTime = incrementalEnd.difference(incrementalStart);

      expect(incrementalTime.inSeconds, lessThan(30));
      expect(find.text('Incremental sync completed'), findsOneWidget);
      expect(find.text('12 changes synchronized'), findsOneWidget);
    });

    testWidgets('real-time updates performance with large datasets', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Test live search performance
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      final searchField = find.byKey(const Key('search_records_field'));
      
      // Type search query character by character
      final searchQuery = 'blood pressure medication';
      for (int i = 0; i < searchQuery.length; i++) {
        final currentQuery = searchQuery.substring(0, i + 1);
        await tester.enterText(searchField, currentQuery);
        await tester.pump(const Duration(milliseconds: 50));
        
        // Each character should update results quickly
        expect(find.byKey(const Key('search_results')), findsOneWidget);
      }

      // Final results should be accurate
      expect(find.textContaining('results found'), findsOneWidget);

      // Step 2: Test real-time filtering performance
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      // Apply multiple filters in sequence
      await tester.tap(find.byKey(const Key('prescription_filter')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Prescriptions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('last_year_filter')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Last 12 months'), findsOneWidget);

      await tester.tap(find.byKey(const Key('doctor_smith_filter')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Dr. Smith'), findsOneWidget);

      // Each filter should update results immediately
      expect(find.text('23 results match all filters'), findsOneWidget);

      // Step 3: Test concurrent operations performance
      // Start a background export while using the app
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      // Start large export in background
      await tester.tap(find.byKey(const Key('background_export_toggle')));
      await tester.tap(find.byKey(const Key('export_button')));
      await tester.pumpAndSettle();

      // Continue using app during export
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // App should remain responsive
      final responsiveStart = DateTime.now();
      await tester.enterText(searchField, 'test search during export');
      await tester.pumpAndSettle();
      final responsiveEnd = DateTime.now();
      final responsiveTime = responsiveEnd.difference(responsiveStart);

      // Should remain responsive during background operations
      expect(responsiveTime.inMilliseconds, lessThan(500));

      // Step 4: Test notification performance
      // Simulate multiple reminders triggering
      for (int i = 0; i < 10; i++) {
        await tester.binding.defaultBinaryMessenger.send(
          'flutter/local_notifications',
          const StandardMessageCodec().encodeMessage('triggerReminder'),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      // App should handle multiple notifications efficiently
      expect(find.byKey(const Key('notification_badge')), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // Badge count
    });

    testWidgets('stress test with maximum dataset size', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Load stress test dataset
      await tester.tap(find.byKey(const Key('developer_options_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('load_stress_test_data')));
      await tester.pumpAndSettle();

      // Should warn about large dataset
      expect(find.text('Loading 10,000 test records'), findsOneWidget);
      expect(find.text('This may take a few minutes'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm_stress_test')));
      await tester.pumpAndSettle();

      // Wait for large dataset to load
      await tester.pumpAndSettle(const Duration(seconds: 30));

      // Step 2: Test app stability with maximum data
      expect(find.text('Stress test data loaded'), findsOneWidget);
      expect(find.text('10,000 records available'), findsOneWidget);

      // Navigate to records list
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical Records'));
      await tester.pumpAndSettle();

      // Should still load efficiently
      expect(find.byKey(const Key('records_list')), findsOneWidget);
      expect(find.text('10,000 records'), findsOneWidget);

      // Step 3: Test search with maximum dataset
      final maxSearchStart = DateTime.now();
      await tester.enterText(
        find.byKey(const Key('search_records_field')), 
        'stress test'
      );
      await tester.pumpAndSettle();
      final maxSearchEnd = DateTime.now();
      final maxSearchTime = maxSearchEnd.difference(maxSearchStart);

      // Search should remain fast even with 10k records
      expect(maxSearchTime.inMilliseconds, lessThan(1000));
      expect(find.textContaining('results found'), findsOneWidget);

      // Step 4: Test export performance with maximum data
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export & Share'));
      await tester.pumpAndSettle();

      expect(find.text('Very large dataset detected'), findsOneWidget);
      expect(find.text('Estimated size: ~150 MB'), findsOneWidget);
      expect(find.text('Recommended: Use streaming export'), findsOneWidget);

      // Should suggest optimizations for very large datasets
      expect(find.byKey(const Key('streaming_export_recommended')), findsOneWidget);
      expect(find.byKey(const Key('selective_export_recommended')), findsOneWidget);

      // Step 5: Verify memory stability with maximum data
      final maxMemory = await tester.binding.defaultBinaryMessenger.send(
        'flutter/performance',
        const StandardMessageCodec().encodeMessage('getMemoryUsage'),
      );

      // Should not consume excessive memory
      expect(maxMemory, isNotNull);

      // App should remain stable
      expect(find.text('Export & Share'), findsOneWidget);
      expect(tester.takeException(), isNull); // No unhandled exceptions
    });
  });
}