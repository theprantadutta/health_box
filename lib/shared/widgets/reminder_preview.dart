import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'reminder_type_selector.dart';
import 'alarm_sound_picker.dart';

/// Widget for previewing how a reminder will appear as notification or alarm
/// Shows a live preview of the notification appearance and allows testing alarm sounds
class ReminderPreview extends StatefulWidget {
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final ReminderType reminderType;
  final String? alarmSound;
  final double? alarmVolume;
  final bool showTestButtons;

  const ReminderPreview({
    super.key,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.reminderType,
    this.alarmSound,
    this.alarmVolume,
    this.showTestButtons = true,
  });

  @override
  State<ReminderPreview> createState() => _ReminderPreviewState();
}

class _ReminderPreviewState extends State<ReminderPreview>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAlarm = false;
  late AnimationController _notificationController;
  late AnimationController _alarmController;
  late Animation<double> _notificationSlideAnimation;
  late Animation<double> _alarmScaleAnimation;

  @override
  void initState() {
    super.initState();

    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _alarmController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _notificationSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.elasticOut,
    ));

    _alarmScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _alarmController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _stopAlarmPreview();
    _audioPlayer.dispose();
    _notificationController.dispose();
    _alarmController.dispose();
    super.dispose();
  }

  Future<void> _showNotificationPreview() async {
    try {
      HapticFeedback.lightImpact();
      await _notificationController.forward();

      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _notificationController.reverse();
        }
      });
    } catch (e) {
      debugPrint('Error showing notification preview: $e');
    }
  }

  Future<void> _showAlarmPreview() async {
    try {
      HapticFeedback.mediumImpact();
      await _alarmController.forward();

      if (widget.alarmSound != null) {
        await _playAlarmPreview();
      }

      // Auto-hide after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _stopAlarmPreview();
          _alarmController.reverse();
        }
      });
    } catch (e) {
      debugPrint('Error showing alarm preview: $e');
    }
  }

  Future<void> _playAlarmPreview() async {
    try {
      if (widget.alarmSound == null) return;

      await _stopAlarmPreview();

      setState(() {
        _isPlayingAlarm = true;
      });

      final soundInfo = widget.alarmSound!.alarmSoundInfo;
      if (soundInfo != null) {
        await _audioPlayer.setVolume(widget.alarmVolume ?? 0.5);
        await _audioPlayer.play(AssetSource(soundInfo.assetPath.replaceFirst('assets/', '')));
      }

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlayingAlarm = false;
          });
        }
      });

    } catch (e) {
      debugPrint('Error playing alarm preview: $e');
      setState(() {
        _isPlayingAlarm = false;
      });
    }
  }

  Future<void> _stopAlarmPreview() async {
    try {
      if (_isPlayingAlarm) {
        await _audioPlayer.stop();
        setState(() {
          _isPlayingAlarm = false;
        });
      }
    } catch (e) {
      debugPrint('Error stopping alarm preview: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reminder Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreviewInfo(context),
            if (widget.showTestButtons) ...[
              const SizedBox(height: 16),
              _buildTestButtons(context),
            ],
            // Notification preview overlay
            AnimatedBuilder(
              animation: _notificationSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _notificationSlideAnimation.value * 80),
                  child: _notificationSlideAnimation.value < 0
                    ? const SizedBox.shrink()
                    : _buildNotificationPreview(context),
                );
              },
            ),
            // Alarm preview overlay
            AnimatedBuilder(
              animation: _alarmScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _alarmScaleAnimation.value,
                  child: _alarmScaleAnimation.value == 0
                    ? const SizedBox.shrink()
                    : _buildAlarmPreview(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.reminderType.icon,
                color: widget.reminderType.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.reminderType.displayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: widget.reminderType.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatTime(widget.scheduledTime),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.description != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.reminderType == ReminderType.alarm ||
              widget.reminderType == ReminderType.both) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.volume_up_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.alarmSound?.alarmSoundInfo?.displayName ?? 'Default'} • ${((widget.alarmVolume ?? 0.5) * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (widget.reminderType == ReminderType.notification ||
            widget.reminderType == ReminderType.both)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showNotificationPreview,
              icon: const Icon(Icons.notifications_outlined, size: 18),
              label: const Text('Test Notification'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
        if ((widget.reminderType == ReminderType.notification ||
             widget.reminderType == ReminderType.both) &&
            (widget.reminderType == ReminderType.alarm ||
             widget.reminderType == ReminderType.both))
          const SizedBox(width: 8),
        if (widget.reminderType == ReminderType.alarm ||
            widget.reminderType == ReminderType.both)
          Expanded(
            child: FilledButton.icon(
              onPressed: _isPlayingAlarm ? _stopAlarmPreview : _showAlarmPreview,
              icon: Icon(
                _isPlayingAlarm ? Icons.stop : Icons.alarm_outlined,
                size: 18,
              ),
              label: Text(_isPlayingAlarm ? 'Stop Alarm' : 'Test Alarm'),
              style: FilledButton.styleFrom(
                backgroundColor: _isPlayingAlarm ? colorScheme.error : Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surfaceContainerHighest,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HealthBox',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.description != null)
                        Text(
                          widget.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  'now',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          color: Colors.orange.withValues(alpha: 0.95),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withValues(alpha: 0.9),
                  Colors.deepOrange.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlayingAlarm ? Icons.alarm_on : Icons.alarm,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ALARM',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAlarmButton(
                      icon: Icons.snooze,
                      label: 'Snooze',
                      onTap: () {
                        _stopAlarmPreview();
                        _alarmController.reverse();
                      },
                    ),
                    _buildAlarmButton(
                      icon: Icons.stop,
                      label: 'Stop',
                      onTap: () {
                        _stopAlarmPreview();
                        _alarmController.reverse();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}