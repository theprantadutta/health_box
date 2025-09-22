// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_drive_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(googleDriveService)
const googleDriveServiceProvider = GoogleDriveServiceProvider._();

final class GoogleDriveServiceProvider
    extends
        $FunctionalProvider<
          GoogleDriveService,
          GoogleDriveService,
          GoogleDriveService
        >
    with $Provider<GoogleDriveService> {
  const GoogleDriveServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveServiceHash();

  @$internal
  @override
  $ProviderElement<GoogleDriveService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleDriveService create(Ref ref) {
    return googleDriveService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleDriveService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleDriveService>(value),
    );
  }
}

String _$googleDriveServiceHash() =>
    r'14679431b6af718789bf770aee0fef143decc746';

@ProviderFor(GoogleDriveAuth)
const googleDriveAuthProvider = GoogleDriveAuthProvider._();

final class GoogleDriveAuthProvider
    extends $AsyncNotifierProvider<GoogleDriveAuth, bool> {
  const GoogleDriveAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveAuthHash();

  @$internal
  @override
  GoogleDriveAuth create() => GoogleDriveAuth();
}

String _$googleDriveAuthHash() => r'061204c0afcaaa4768594dd19f133b5a5f7eaa58';

abstract class _$GoogleDriveAuth extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SyncSettings)
const syncSettingsProvider = SyncSettingsProvider._();

final class SyncSettingsProvider
    extends $AsyncNotifierProvider<SyncSettings, SyncConfiguration> {
  const SyncSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSettingsHash();

  @$internal
  @override
  SyncSettings create() => SyncSettings();
}

String _$syncSettingsHash() => r'366de11a646e9f4c7fd9ac439797ea0901a94d4e';

abstract class _$SyncSettings extends $AsyncNotifier<SyncConfiguration> {
  FutureOr<SyncConfiguration> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SyncConfiguration>, SyncConfiguration>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncConfiguration>, SyncConfiguration>,
              AsyncValue<SyncConfiguration>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(googleDriveBackups)
const googleDriveBackupsProvider = GoogleDriveBackupsProvider._();

final class GoogleDriveBackupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BackupFile>>,
          List<BackupFile>,
          FutureOr<List<BackupFile>>
        >
    with $FutureModifier<List<BackupFile>>, $FutureProvider<List<BackupFile>> {
  const GoogleDriveBackupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveBackupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveBackupsHash();

  @$internal
  @override
  $FutureProviderElement<List<BackupFile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BackupFile>> create(Ref ref) {
    return googleDriveBackups(ref);
  }
}

String _$googleDriveBackupsHash() =>
    r'4b8a86720b7960fe0f51a7e4cfd5bfd59854a304';

@ProviderFor(BackupOperations)
const backupOperationsProvider = BackupOperationsProvider._();

final class BackupOperationsProvider
    extends $AsyncNotifierProvider<BackupOperations, BackupProgress> {
  const BackupOperationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupOperationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupOperationsHash();

  @$internal
  @override
  BackupOperations create() => BackupOperations();
}

String _$backupOperationsHash() => r'df74319181343a11c1ccf13bf36cad817d12d22c';

abstract class _$BackupOperations extends $AsyncNotifier<BackupProgress> {
  FutureOr<BackupProgress> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<BackupProgress>, BackupProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BackupProgress>, BackupProgress>,
              AsyncValue<BackupProgress>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
