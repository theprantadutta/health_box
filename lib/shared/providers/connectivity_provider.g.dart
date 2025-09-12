// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(ConnectivityNotifier)
const connectivityNotifierProvider = ConnectivityNotifierProvider._();

final class ConnectivityNotifierProvider
    extends $AsyncNotifierProvider<ConnectivityNotifier, ConnectivityStatus> {
  const ConnectivityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityNotifierHash();

  @$internal
  @override
  ConnectivityNotifier create() => ConnectivityNotifier();
}

String _$connectivityNotifierHash() =>
    r'e9e14c427f00b56126f7b2031408c6a0e8357f84';

abstract class _$ConnectivityNotifier
    extends $AsyncNotifier<ConnectivityStatus> {
  FutureOr<ConnectivityStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<ConnectivityStatus>, ConnectivityStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ConnectivityStatus>, ConnectivityStatus>,
              AsyncValue<ConnectivityStatus>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(OfflineQueue)
const offlineQueueProvider = OfflineQueueProvider._();

final class OfflineQueueProvider
    extends $NotifierProvider<OfflineQueue, List<OfflineAction>> {
  const OfflineQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineQueueHash();

  @$internal
  @override
  OfflineQueue create() => OfflineQueue();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OfflineAction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OfflineAction>>(value),
    );
  }
}

String _$offlineQueueHash() => r'608f0d7e69964d778d6e5cec3cdd8ab2d3e65ff8';

abstract class _$OfflineQueue extends $Notifier<List<OfflineAction>> {
  List<OfflineAction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<OfflineAction>, List<OfflineAction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<OfflineAction>, List<OfflineAction>>,
              List<OfflineAction>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(isOnline)
const isOnlineProvider = IsOnlineProvider._();

final class IsOnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnlineHash() => r'957fec9f801364e2b63676bdb3024d625ff3c052';

@ProviderFor(isOffline)
const isOfflineProvider = IsOfflineProvider._();

final class IsOfflineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOfflineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOfflineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOffline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOfflineHash() => r'6cccccf5690dde221cb32095eb589227e9c0ecf8';

@ProviderFor(hasWifi)
const hasWifiProvider = HasWifiProvider._();

final class HasWifiProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const HasWifiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasWifiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasWifiHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasWifi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasWifiHash() => r'e7026843f82baedf5a5942f059c81bb148f8edaa';

@ProviderFor(hasMobile)
const hasMobileProvider = HasMobileProvider._();

final class HasMobileProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const HasMobileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasMobileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasMobileHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasMobile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasMobileHash() => r'850599aa2c319802e121eafe68ca97473446cdb6';

@ProviderFor(pendingOfflineActions)
const pendingOfflineActionsProvider = PendingOfflineActionsProvider._();

final class PendingOfflineActionsProvider
    extends
        $FunctionalProvider<
          List<OfflineAction>,
          List<OfflineAction>,
          List<OfflineAction>
        >
    with $Provider<List<OfflineAction>> {
  const PendingOfflineActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOfflineActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOfflineActionsHash();

  @$internal
  @override
  $ProviderElement<List<OfflineAction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OfflineAction> create(Ref ref) {
    return pendingOfflineActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OfflineAction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OfflineAction>>(value),
    );
  }
}

String _$pendingOfflineActionsHash() =>
    r'987309bea279e0bb1b055ad8803c6fd7c106de58';

@ProviderFor(failedOfflineActions)
const failedOfflineActionsProvider = FailedOfflineActionsProvider._();

final class FailedOfflineActionsProvider
    extends
        $FunctionalProvider<
          List<OfflineAction>,
          List<OfflineAction>,
          List<OfflineAction>
        >
    with $Provider<List<OfflineAction>> {
  const FailedOfflineActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'failedOfflineActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$failedOfflineActionsHash();

  @$internal
  @override
  $ProviderElement<List<OfflineAction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OfflineAction> create(Ref ref) {
    return failedOfflineActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OfflineAction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OfflineAction>>(value),
    );
  }
}

String _$failedOfflineActionsHash() =>
    r'd5655a47da27f0d1c8efd6ae61b9b1852dfa6262';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
