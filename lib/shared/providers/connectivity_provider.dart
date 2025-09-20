// import 'dart:async';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../services/logging_service.dart';
// import '../error/error_handler.dart';

// part 'connectivity_provider.g.dart';

// enum ConnectivityState { unknown, online, offline, limited }

// class ConnectivityStatus {
//   final ConnectivityState state;
//   final List<ConnectivityResult> connectionTypes;
//   final DateTime lastCheck;
//   final String? lastError;

//   const ConnectivityStatus({
//     required this.state,
//     required this.connectionTypes,
//     required this.lastCheck,
//     this.lastError,
//   });

//   bool get isOnline => state == ConnectivityState.online;
//   bool get isOffline => state == ConnectivityState.offline;
//   bool get hasWifi => connectionTypes.contains(ConnectivityResult.wifi);
//   bool get hasMobile => connectionTypes.contains(ConnectivityResult.mobile);
//   bool get hasEthernet => connectionTypes.contains(ConnectivityResult.ethernet);

//   ConnectivityStatus copyWith({
//     ConnectivityState? state,
//     List<ConnectivityResult>? connectionTypes,
//     DateTime? lastCheck,
//     String? lastError,
//   }) {
//     return ConnectivityStatus(
//       state: state ?? this.state,
//       connectionTypes: connectionTypes ?? this.connectionTypes,
//       lastCheck: lastCheck ?? this.lastCheck,
//       lastError: lastError ?? this.lastError,
//     );
//   }

//   @override
//   String toString() {
//     return 'ConnectivityStatus(state: $state, types: $connectionTypes, lastCheck: $lastCheck)';
//   }
// }

// @riverpod
// class ConnectivityNotifier extends _$ConnectivityNotifier
//     with ErrorHandlerMixin {
//   late final Connectivity _connectivity;
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//   Timer? _connectionTestTimer;
//   bool _disposed = false;

//   static const Duration _connectionTestInterval = Duration(seconds: 30);
//   static const Duration _connectionTimeout = Duration(seconds: 10);

//   @override
//   Future<ConnectivityStatus> build() async {
//     _connectivity = Connectivity();

//     // Set up cleanup on disposal
//     ref.onDispose(() {
//       _disposed = true;
//       _connectivitySubscription?.cancel();
//       _connectionTestTimer?.cancel();
//     });

//     await _initialize();

//     return ConnectivityStatus(
//       state: ConnectivityState.unknown,
//       connectionTypes: [],
//       lastCheck: DateTime.now(),
//     );
//   }

//   Future<void> _initialize() async {
//     await runGuarded(() async {
//       logger.debug(
//         'Initializing connectivity monitoring',
//         tag: 'ConnectivityProvider',
//       );

//       // Get initial connectivity state
//       await _checkConnectivity();

//       // Start listening for connectivity changes
//       _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
//         _onConnectivityChanged,
//         onError: _onConnectivityError,
//       );

//       // Start periodic connection tests
//       _startConnectionTests();
//     });
//   }

//   void _onConnectivityChanged(List<ConnectivityResult> result) {
//     if (_disposed) return;

//     logger.debug('Connectivity changed: $result', tag: 'ConnectivityProvider');

//     runGuarded(() async {
//       await _updateConnectivityState(result);
//     });
//   }

//   void _onConnectivityError(Object error, StackTrace stackTrace) {
//     if (_disposed) return;

//     logger.error(
//       'Connectivity stream error',
//       tag: 'ConnectivityProvider',
//       error: error,
//       stackTrace: stackTrace,
//     );

//     handleError(error, stackTrace: stackTrace);

//     state = AsyncValue.data(
//       state.value!.copyWith(
//         state: ConnectivityState.unknown,
//         lastError: error.toString(),
//         lastCheck: DateTime.now(),
//       ),
//     );
//   }

//   Future<void> _updateConnectivityState(
//     List<ConnectivityResult> results,
//   ) async {
//     final hasConnection = results.any(
//       (result) => result != ConnectivityResult.none,
//     );

//     if (!hasConnection) {
//       state = AsyncValue.data(
//         state.value!.copyWith(
//           state: ConnectivityState.offline,
//           connectionTypes: results,
//           lastCheck: DateTime.now(),
//           lastError: null,
//         ),
//       );
//       return;
//     }

//     // Test actual internet connectivity
//     final isReallyOnline = await _testInternetConnection();

//     state = AsyncValue.data(
//       state.value!.copyWith(
//         state: isReallyOnline
//             ? ConnectivityState.online
//             : ConnectivityState.limited,
//         connectionTypes: results,
//         lastCheck: DateTime.now(),
//         lastError: null,
//       ),
//     );
//   }

//   Future<bool> _testInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup(
//         'google.com',
//       ).timeout(_connectionTimeout);

//       final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

//       logger.trace(
//         'Internet connection test: ${isConnected ? "success" : "failed"}',
//         tag: 'ConnectivityProvider',
//       );

//       return isConnected;
//     } catch (error) {
//       logger.trace(
//         'Internet connection test failed: $error',
//         tag: 'ConnectivityProvider',
//       );
//       return false;
//     }
//   }

//   void _startConnectionTests() {
//     _connectionTestTimer = Timer.periodic(_connectionTestInterval, (_) {
//       if (!_disposed) {
//         runGuarded(() async {
//           await _checkConnectivity();
//         });
//       }
//     });
//   }

//   Future<void> _checkConnectivity() async {
//     if (_disposed) return;

//     try {
//       final results = await _connectivity.checkConnectivity();
//       await _updateConnectivityState(results);
//     } catch (error, stackTrace) {
//       logger.error(
//         'Failed to check connectivity',
//         tag: 'ConnectivityProvider',
//         error: error,
//         stackTrace: stackTrace,
//       );

//       handleError(error, stackTrace: stackTrace);

//       state = AsyncValue.data(
//         state.value!.copyWith(
//           state: ConnectivityState.unknown,
//           lastError: error.toString(),
//           lastCheck: DateTime.now(),
//         ),
//       );
//     }
//   }

//   Future<void> refresh() async {
//     logger.debug(
//       'Manual connectivity refresh requested',
//       tag: 'ConnectivityProvider',
//     );
//     await _checkConnectivity();
//   }

//   Future<bool> testConnection() async {
//     logger.debug('Testing internet connection', tag: 'ConnectivityProvider');

//     return runGuarded(() async {
//       final isOnline = await _testInternetConnection();

//       // Update state if connection status changed
//       final currentState = state.value!;
//       if ((isOnline && currentState.isOffline) ||
//           (!isOnline && currentState.isOnline)) {
//         state = AsyncValue.data(
//           currentState.copyWith(
//             state: isOnline
//                 ? ConnectivityState.online
//                 : ConnectivityState.limited,
//             lastCheck: DateTime.now(),
//           ),
//         );
//       }

//       return isOnline;
//     }, fallback: false);
//   }
// }

// // Offline queue for actions that need to be performed when back online
// class OfflineAction {
//   final String id;
//   final String type;
//   final Map<String, dynamic> data;
//   final DateTime createdAt;
//   final int retryCount;
//   final int maxRetries;

//   const OfflineAction({
//     required this.id,
//     required this.type,
//     required this.data,
//     required this.createdAt,
//     this.retryCount = 0,
//     this.maxRetries = 3,
//   });

//   OfflineAction copyWith({
//     String? id,
//     String? type,
//     Map<String, dynamic>? data,
//     DateTime? createdAt,
//     int? retryCount,
//     int? maxRetries,
//   }) {
//     return OfflineAction(
//       id: id ?? this.id,
//       type: type ?? this.type,
//       data: data ?? this.data,
//       createdAt: createdAt ?? this.createdAt,
//       retryCount: retryCount ?? this.retryCount,
//       maxRetries: maxRetries ?? this.maxRetries,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'type': type,
//       'data': data,
//       'createdAt': createdAt.toIso8601String(),
//       'retryCount': retryCount,
//       'maxRetries': maxRetries,
//     };
//   }

//   factory OfflineAction.fromJson(Map<String, dynamic> json) {
//     return OfflineAction(
//       id: json['id'] as String,
//       type: json['type'] as String,
//       data: json['data'] as Map<String, dynamic>,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       retryCount: json['retryCount'] as int? ?? 0,
//       maxRetries: json['maxRetries'] as int? ?? 3,
//     );
//   }

//   @override
//   String toString() {
//     return 'OfflineAction(id: $id, type: $type, retryCount: $retryCount)';
//   }
// }

// @riverpod
// class OfflineQueue extends _$OfflineQueue with ErrorHandlerMixin {
//   @override
//   List<OfflineAction> build() {
//     return [];
//   }

//   void addAction(OfflineAction action) {
//     logger.debug(
//       'Adding offline action: ${action.type}',
//       tag: 'OfflineQueue',
//       context: {'actionId': action.id},
//     );

//     state = [...state, action];
//   }

//   void removeAction(String actionId) {
//     logger.debug(
//       'Removing offline action',
//       tag: 'OfflineQueue',
//       context: {'actionId': actionId},
//     );

//     state = state.where((action) => action.id != actionId).toList();
//   }

//   void incrementRetry(String actionId) {
//     state = state.map((action) {
//       if (action.id == actionId) {
//         return action.copyWith(retryCount: action.retryCount + 1);
//       }
//       return action;
//     }).toList();
//   }

//   List<OfflineAction> getPendingActions() {
//     return state
//         .where((action) => action.retryCount < action.maxRetries)
//         .toList();
//   }

//   List<OfflineAction> getFailedActions() {
//     return state
//         .where((action) => action.retryCount >= action.maxRetries)
//         .toList();
//   }

//   void clearFailedActions() {
//     logger.info('Clearing failed offline actions', tag: 'OfflineQueue');
//     state = state
//         .where((action) => action.retryCount < action.maxRetries)
//         .toList();
//   }

//   void clearAllActions() {
//     logger.info('Clearing all offline actions', tag: 'OfflineQueue');
//     state = [];
//   }
// }

// // Computed providers
// @riverpod
// bool isOnline(Ref ref) {
//   final connectivity = ref.watch(connectivityNotifierProvider);
//   return connectivity.when(
//     data: (status) => status.isOnline,
//     loading: () => false,
//     error: (_, __) => false,
//   );
// }

// @riverpod
// bool isOffline(Ref ref) {
//   final connectivity = ref.watch(connectivityNotifierProvider);
//   return connectivity.when(
//     data: (status) => status.isOffline,
//     loading: () => true,
//     error: (_, __) => true,
//   );
// }

// @riverpod
// bool hasWifi(Ref ref) {
//   final connectivity = ref.watch(connectivityNotifierProvider);
//   return connectivity.when(
//     data: (status) => status.hasWifi,
//     loading: () => false,
//     error: (_, __) => false,
//   );
// }

// @riverpod
// bool hasMobile(Ref ref) {
//   final connectivity = ref.watch(connectivityNotifierProvider);
//   return connectivity.when(
//     data: (status) => status.hasMobile,
//     loading: () => false,
//     error: (_, __) => false,
//   );
// }

// @riverpod
// List<OfflineAction> pendingOfflineActions(Ref ref) {
//   final queue = ref.watch(offlineQueueProvider.notifier);
//   return queue.getPendingActions();
// }

// @riverpod
// List<OfflineAction> failedOfflineActions(Ref ref) {
//   final queue = ref.watch(offlineQueueProvider.notifier);
//   return queue.getFailedActions();
// }

// // Helper mixin for widgets that need offline functionality
// mixin OfflineCapable {
//   void executeWhenOnline(
//     dynamic ref,
//     Future<void> Function() action, {
//     String? actionType,
//     Map<String, dynamic>? actionData,
//   }) {
//     final isOnline = (ref as dynamic).read(isOnlineProvider);

//     if (isOnline) {
//       action();
//     } else {
//       final offlineQueue = (ref as dynamic).read(offlineQueueProvider.notifier);

//       if (actionType != null) {
//         final offlineAction = OfflineAction(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           type: actionType,
//           data: actionData ?? {},
//           createdAt: DateTime.now(),
//         );

//         offlineQueue.addAction(offlineAction);
//       }

//       logger.info(
//         'Action queued for when online: ${actionType ?? "unknown"}',
//         tag: 'OfflineCapable',
//       );
//     }
//   }
// }
