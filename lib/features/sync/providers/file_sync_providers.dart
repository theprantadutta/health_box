import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/sync_preferences.dart';
import '../services/file_sync_preferences_service.dart';

// Service provider
final fileSyncPreferencesServiceProvider = Provider<FileSyncPreferencesService>((ref) {
  return FileSyncPreferencesService();
});

// Preferences provider with state management
final fileSyncPreferencesProvider = StateNotifierProvider<FileSyncPreferencesNotifier, AsyncValue<SyncPreferencesData>>((ref) {
  final service = ref.read(fileSyncPreferencesServiceProvider);
  return FileSyncPreferencesNotifier(service);
});

// Sync statistics provider
final syncStatsProvider = FutureProvider<SyncStatsSummary>((ref) async {
  final service = ref.read(fileSyncPreferencesServiceProvider);
  return await service.getSyncStats();
});

// Individual preference providers for quick access
final fileUploadEnabledProvider = Provider<bool>((ref) {
  final prefsAsync = ref.watch(fileSyncPreferencesProvider);
  return prefsAsync.maybeWhen(
    data: (prefs) => prefs.fileUploadEnabled,
    orElse: () => true, // Default to enabled
  );
});

final autoUploadEnabledProvider = Provider<bool>((ref) {
  final prefsAsync = ref.watch(fileSyncPreferencesProvider);
  return prefsAsync.maybeWhen(
    data: (prefs) => prefs.autoUpload,
    orElse: () => true, // Default to enabled
  );
});

final wifiOnlyUploadProvider = Provider<bool>((ref) {
  final prefsAsync = ref.watch(fileSyncPreferencesProvider);
  return prefsAsync.maybeWhen(
    data: (prefs) => prefs.wifiOnlyUpload,
    orElse: () => true, // Default to WiFi only
  );
});

final maxFileSizeBytesProvider = Provider<int>((ref) {
  final prefsAsync = ref.watch(fileSyncPreferencesProvider);
  return prefsAsync.maybeWhen(
    data: (prefs) => prefs.maxFileSizeMb * 1024 * 1024,
    orElse: () => 50 * 1024 * 1024, // Default to 50MB
  );
});

// File type filter providers
final fileTypeFiltersProvider = Provider<Map<FileTypeFilter, bool>>((ref) {
  final prefsAsync = ref.watch(fileSyncPreferencesProvider);
  return prefsAsync.maybeWhen(
    data: (prefs) => {
      FileTypeFilter.images: prefs.syncImages,
      FileTypeFilter.pdfs: prefs.syncPdfs,
      FileTypeFilter.documents: prefs.syncDocuments,
    },
    orElse: () => {
      FileTypeFilter.images: true,
      FileTypeFilter.pdfs: true,
      FileTypeFilter.documents: true,
    },
  );
});

// State notifier for managing preferences
class FileSyncPreferencesNotifier extends StateNotifier<AsyncValue<SyncPreferencesData>> {
  final FileSyncPreferencesService _service;

  FileSyncPreferencesNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  // Load current preferences
  Future<void> _loadPreferences() async {
    try {
      state = const AsyncValue.loading();
      final preferences = await _service.getPreferences();
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Update preferences
  Future<void> updatePreferences({
    bool? fileUploadEnabled,
    bool? syncImages,
    bool? syncPdfs,
    bool? syncDocuments,
    int? maxFileSizeMb,
    bool? wifiOnlyUpload,
    bool? autoUpload,
    int? maxUploadRetries,
  }) async {
    try {
      // Optimistically update the UI
      state.whenData((current) {
        state = AsyncValue.data(current.copyWith(
          fileUploadEnabled: fileUploadEnabled ?? current.fileUploadEnabled,
          syncImages: syncImages ?? current.syncImages,
          syncPdfs: syncPdfs ?? current.syncPdfs,
          syncDocuments: syncDocuments ?? current.syncDocuments,
          maxFileSizeMb: maxFileSizeMb ?? current.maxFileSizeMb,
          wifiOnlyUpload: wifiOnlyUpload ?? current.wifiOnlyUpload,
          autoUpload: autoUpload ?? current.autoUpload,
          maxUploadRetries: maxUploadRetries ?? current.maxUploadRetries,
          updatedAt: DateTime.now(),
        ));
      });

      // Update in database
      final updated = await _service.updatePreferences(
        fileUploadEnabled: fileUploadEnabled,
        syncImages: syncImages,
        syncPdfs: syncPdfs,
        syncDocuments: syncDocuments,
        maxFileSizeMb: maxFileSizeMb,
        wifiOnlyUpload: wifiOnlyUpload,
        autoUpload: autoUpload,
        maxUploadRetries: maxUploadRetries,
      );

      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      // Revert optimistic update on error
      await _loadPreferences();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      state = const AsyncValue.loading();
      final preferences = await _service.resetToDefaults();
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Check if a file should be synced
  Future<bool> shouldSyncFile(String fileName, int fileSizeBytes) async {
    try {
      final preferences = await _service.getPreferences();

      if (!preferences.fileUploadEnabled) return false;

      // Check file size
      if (!await _service.isFileSizeAllowed(fileSizeBytes)) return false;

      // Check file type
      final extension = fileName.split('.').last.toLowerCase();
      return preferences.shouldSyncFileType(extension);
    } catch (e) {
      return false; // Default to not syncing on error
    }
  }

  // Toggle specific file type
  Future<void> toggleFileType(FileTypeFilter fileType, bool enabled) async {
    switch (fileType) {
      case FileTypeFilter.images:
        await updatePreferences(syncImages: enabled);
        break;
      case FileTypeFilter.pdfs:
        await updatePreferences(syncPdfs: enabled);
        break;
      case FileTypeFilter.documents:
        await updatePreferences(syncDocuments: enabled);
        break;
    }
  }

  // Refresh preferences from database
  Future<void> refresh() async {
    await _loadPreferences();
  }
}

// Helper providers for common operations
final shouldSyncFileProvider = FutureProvider.family<bool, ({String fileName, int fileSize})>((ref, params) async {
  final notifier = ref.read(fileSyncPreferencesProvider.notifier);
  return await notifier.shouldSyncFile(params.fileName, params.fileSize);
});

final isFileSizeAllowedProvider = Provider.family<bool, int>((ref, fileSizeBytes) {
  final maxSizeBytes = ref.watch(maxFileSizeBytesProvider);
  return fileSizeBytes <= maxSizeBytes;
});

final fileTypeEnabledProvider = Provider.family<bool, String>((ref, fileName) {
  final filters = ref.watch(fileTypeFiltersProvider);
  final extension = fileName.split('.').last.toLowerCase();
  final fileType = FileTypeFilter.fromExtension(extension);
  return fileType != null ? (filters[fileType] ?? false) : false;
});