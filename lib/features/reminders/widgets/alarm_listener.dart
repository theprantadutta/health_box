import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_router.dart';

/// Global listener that navigates to alarm screen when alarm rings
class AlarmListener extends StatefulWidget {
  final Widget child;

  const AlarmListener({
    super.key,
    required this.child,
  });

  @override
  State<AlarmListener> createState() => _AlarmListenerState();
}

class _AlarmListenerState extends State<AlarmListener> {
  @override
  void initState() {
    super.initState();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    // Listen to alarm ring stream - simple approach like BetterClock
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint('🔔 Alarm ringing! ID: ${alarmSettings.id}');

      // Navigate using root navigator key to avoid context issues
      rootNavigatorKey.currentContext?.go(
        '/alarm',
        extra: alarmSettings,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
