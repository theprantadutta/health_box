import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CustomAppLifecycleState {
  resumed,
  inactive,
  paused,
  detached,
  hidden,
}

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._();
  
  static final AppLifecycleService _instance = AppLifecycleService._();
  static AppLifecycleService get instance => _instance;

  final _lifecycleStateNotifier = ValueNotifier<CustomAppLifecycleState>(
    CustomAppLifecycleState.resumed,
  );
  
  final List<VoidCallback> _pauseCallbacks = [];
  final List<VoidCallback> _resumeCallbacks = [];
  final List<VoidCallback> _detachCallbacks = [];
  final List<VoidCallback> _inactiveCallbacks = [];
  final List<VoidCallback> _hiddenCallbacks = [];

  ValueNotifier<CustomAppLifecycleState> get lifecycleState => _lifecycleStateNotifier;
  
  bool _isInitialized = false;
  DateTime? _lastPausedTime;
  Duration _backgroundDuration = Duration.zero;

  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    debugPrint('AppLifecycleService initialized');
  }

  void dispose() {
    if (!_isInitialized) return;
    
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    
    _pauseCallbacks.clear();
    _resumeCallbacks.clear();
    _detachCallbacks.clear();
    _inactiveCallbacks.clear();
    _hiddenCallbacks.clear();
    
    debugPrint('AppLifecycleService disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('App lifecycle state changed: $state');
    
    final customState = _mapFlutterStateToCustomState(state);
    _lifecycleStateNotifier.value = customState;
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumed();
        break;
      case AppLifecycleState.inactive:
        _handleInactive();
        break;
      case AppLifecycleState.paused:
        _handlePaused();
        break;
      case AppLifecycleState.detached:
        _handleDetached();
        break;
      case AppLifecycleState.hidden:
        _handleHidden();
        break;
    }
    
    super.didChangeAppLifecycleState(state);
  }

  CustomAppLifecycleState _mapFlutterStateToCustomState(AppLifecycleState flutterState) {
    switch (flutterState) {
      case AppLifecycleState.resumed:
        return CustomAppLifecycleState.resumed;
      case AppLifecycleState.inactive:
        return CustomAppLifecycleState.inactive;
      case AppLifecycleState.paused:
        return CustomAppLifecycleState.paused;
      case AppLifecycleState.detached:
        return CustomAppLifecycleState.detached;
      case AppLifecycleState.hidden:
        return CustomAppLifecycleState.hidden;
    }
  }

  void _handleResumed() {
    if (_lastPausedTime != null) {
      _backgroundDuration = DateTime.now().difference(_lastPausedTime!);
      debugPrint('App resumed after ${_backgroundDuration.inSeconds} seconds');
      
      if (_backgroundDuration.inMinutes > 5) {
        _handleLongBackgroundReturn();
      }
      
      _lastPausedTime = null;
    }
    
    for (final callback in _resumeCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in resume callback: $e');
      }
    }
  }

  void _handleInactive() {
    for (final callback in _inactiveCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in inactive callback: $e');
      }
    }
  }

  void _handlePaused() {
    _lastPausedTime = DateTime.now();
    debugPrint('App paused at: $_lastPausedTime');
    
    _handleDataPersistence();
    
    for (final callback in _pauseCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in pause callback: $e');
      }
    }
  }

  void _handleDetached() {
    debugPrint('App detached - performing cleanup');
    
    _handleAppShutdown();
    
    for (final callback in _detachCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in detach callback: $e');
      }
    }
  }

  void _handleHidden() {
    debugPrint('App hidden');
    
    for (final callback in _hiddenCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in hidden callback: $e');
      }
    }
  }

  void _handleLongBackgroundReturn() {
    debugPrint('App returned from long background duration');
    
  }

  void _handleDataPersistence() {
    debugPrint('Persisting data before app goes to background');
    
  }

  void _handleAppShutdown() {
    debugPrint('App is shutting down - final cleanup');
    
  }

  void addResumeCallback(VoidCallback callback) {
    _resumeCallbacks.add(callback);
  }

  void addPauseCallback(VoidCallback callback) {
    _pauseCallbacks.add(callback);
  }

  void addDetachCallback(VoidCallback callback) {
    _detachCallbacks.add(callback);
  }

  void addInactiveCallback(VoidCallback callback) {
    _inactiveCallbacks.add(callback);
  }

  void addHiddenCallback(VoidCallback callback) {
    _hiddenCallbacks.add(callback);
  }

  void removeResumeCallback(VoidCallback callback) {
    _resumeCallbacks.remove(callback);
  }

  void removePauseCallback(VoidCallback callback) {
    _pauseCallbacks.remove(callback);
  }

  void removeDetachCallback(VoidCallback callback) {
    _detachCallbacks.remove(callback);
  }

  void removeInactiveCallback(VoidCallback callback) {
    _inactiveCallbacks.remove(callback);
  }

  void removeHiddenCallback(VoidCallback callback) {
    _hiddenCallbacks.remove(callback);
  }

  Duration get timeSinceLastPause => _backgroundDuration;
  
  bool get wasInBackgroundLongTime => _backgroundDuration.inMinutes > 5;
  
  bool get isAppActive => _lifecycleStateNotifier.value == CustomAppLifecycleState.resumed;
  
  bool get isAppInactive => _lifecycleStateNotifier.value == CustomAppLifecycleState.inactive;
  
  bool get isAppPaused => _lifecycleStateNotifier.value == CustomAppLifecycleState.paused;
  
  bool get isAppDetached => _lifecycleStateNotifier.value == CustomAppLifecycleState.detached;
  
  bool get isAppHidden => _lifecycleStateNotifier.value == CustomAppLifecycleState.hidden;

  Future<void> requestAppRestart() async {
    try {
      await SystemNavigator.pop();
    } catch (e) {
      debugPrint('Failed to restart app: $e');
    }
  }

  void setSystemUIOverlayStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  Future<void> setPreferredOrientations(List<DeviceOrientation> orientations) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  Future<void> enableSystemUIMode(SystemUiMode mode) async {
    await SystemChrome.setEnabledSystemUIMode(mode);
  }

  static void scheduleCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  static void scheduleDelayedCallback(VoidCallback callback, Duration delay) {
    Future.delayed(delay, callback);
  }
}

final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  final service = AppLifecycleService.instance;
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final appLifecycleStateProvider = StreamProvider<CustomAppLifecycleState>((ref) {
  final service = ref.watch(appLifecycleServiceProvider);
  service.initialize();
  
  return Stream<CustomAppLifecycleState>.periodic(
    const Duration(milliseconds: 100),
    (count) => service.lifecycleState.value,
  ).distinct();
});

class AppLifecycleWidget extends ConsumerStatefulWidget {
  const AppLifecycleWidget({
    super.key,
    required this.child,
    this.onResume,
    this.onPause,
    this.onDetach,
    this.onInactive,
    this.onHidden,
  });

  final Widget child;
  final VoidCallback? onResume;
  final VoidCallback? onPause;
  final VoidCallback? onDetach;
  final VoidCallback? onInactive;
  final VoidCallback? onHidden;

  @override
  ConsumerState<AppLifecycleWidget> createState() => _AppLifecycleWidgetState();
}

class _AppLifecycleWidgetState extends ConsumerState<AppLifecycleWidget> {
  late AppLifecycleService _service;

  @override
  void initState() {
    super.initState();
    _service = ref.read(appLifecycleServiceProvider);
    _service.initialize();
    
    _setupCallbacks();
  }

  void _setupCallbacks() {
    if (widget.onResume != null) {
      _service.addResumeCallback(widget.onResume!);
    }
    
    if (widget.onPause != null) {
      _service.addPauseCallback(widget.onPause!);
    }
    
    if (widget.onDetach != null) {
      _service.addDetachCallback(widget.onDetach!);
    }
    
    if (widget.onInactive != null) {
      _service.addInactiveCallback(widget.onInactive!);
    }
    
    if (widget.onHidden != null) {
      _service.addHiddenCallback(widget.onHidden!);
    }
  }

  @override
  void dispose() {
    if (widget.onResume != null) {
      _service.removeResumeCallback(widget.onResume!);
    }
    
    if (widget.onPause != null) {
      _service.removePauseCallback(widget.onPause!);
    }
    
    if (widget.onDetach != null) {
      _service.removeDetachCallback(widget.onDetach!);
    }
    
    if (widget.onInactive != null) {
      _service.removeInactiveCallback(widget.onInactive!);
    }
    
    if (widget.onHidden != null) {
      _service.removeHiddenCallback(widget.onHidden!);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifecycleState = ref.watch(appLifecycleStateProvider);
    
    return lifecycleState.when(
      data: (state) {
        debugPrint('Current lifecycle state: $state');
        return widget.child;
      },
      loading: () => widget.child,
      error: (error, stack) {
        debugPrint('Lifecycle state error: $error');
        return widget.child;
      },
    );
  }
}