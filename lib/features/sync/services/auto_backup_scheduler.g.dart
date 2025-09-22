// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_backup_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(autoBackupScheduler)
const autoBackupSchedulerProvider = AutoBackupSchedulerProvider._();

final class AutoBackupSchedulerProvider
    extends
        $FunctionalProvider<
          AutoBackupScheduler,
          AutoBackupScheduler,
          AutoBackupScheduler
        >
    with $Provider<AutoBackupScheduler> {
  const AutoBackupSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoBackupSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoBackupSchedulerHash();

  @$internal
  @override
  $ProviderElement<AutoBackupScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoBackupScheduler create(Ref ref) {
    return autoBackupScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoBackupScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoBackupScheduler>(value),
    );
  }
}

String _$autoBackupSchedulerHash() =>
    r'beeec8800491be3003a73f753f625673ef417c50';
