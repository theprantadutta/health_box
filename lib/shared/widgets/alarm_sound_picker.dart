import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Widget for selecting alarm sounds with preview functionality
/// Allows users to choose from different alarm sounds and preview them
class AlarmSoundPicker extends StatefulWidget {
  final String selectedSound;
  final ValueChanged<String> onSoundChanged;
  final bool enabled;
  final bool showPreview;
  final double previewVolume;

  const AlarmSoundPicker({
    super.key,
    required this.selectedSound,
    required this.onSoundChanged,
    this.enabled = true,
    this.showPreview = true,
    this.previewVolume = 0.5,
  });

  @override
  State<AlarmSoundPicker> createState() => _AlarmSoundPickerState();
}

class _AlarmSoundPickerState extends State<AlarmSoundPicker> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingSound;
  bool _isPlaying = false;

  static const Map<String, AlarmSoundInfo> _alarmSounds = {
    'gentle': AlarmSoundInfo(
      key: 'gentle',
      displayName: 'Gentle Chime',
      description: 'Soft, peaceful chime sound',
      assetPath: 'assets/sounds/gentle_alarm.mp3',
      icon: Icons.music_note_outlined,
      color: Colors.green,
    ),
    'urgent': AlarmSoundInfo(
      key: 'urgent',
      displayName: 'Urgent Alert',
      description: 'Strong, attention-grabbing alarm',
      assetPath: 'assets/sounds/urgent_alarm.mp3',
      icon: Icons.warning_amber_outlined,
      color: Colors.red,
    ),
    'chime': AlarmSoundInfo(
      key: 'chime',
      displayName: 'Peaceful Chime',
      description: 'Calming bell-like chime',
      assetPath: 'assets/sounds/chime_alarm.mp3',
      icon: Icons.notifications_outlined,
      color: Colors.blue,
    ),
  };

  @override
  void dispose() {
    _stopCurrentSound();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundKey) async {
    try {
      // Stop any currently playing sound
      await _stopCurrentSound();

      final soundInfo = _alarmSounds[soundKey];
      if (soundInfo == null) return;

      setState(() {
        _currentlyPlayingSound = soundKey;
        _isPlaying = true;
      });

      // Set volume for preview
      await _audioPlayer.setVolume(widget.previewVolume);

      // Play the sound from assets
      await _audioPlayer.play(AssetSource(soundInfo.assetPath.replaceFirst('assets/', '')));

      // Provide haptic feedback
      if (widget.enabled) {
        HapticFeedback.lightImpact();
      }

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _currentlyPlayingSound = null;
            _isPlaying = false;
          });
        }
      });

    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
      setState(() {
        _currentlyPlayingSound = null;
        _isPlaying = false;
      });
    }
  }

  Future<void> _stopCurrentSound() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingSound = null;
          _isPlaying = false;
        });
      }
    } catch (e) {
      debugPrint('Error stopping alarm sound: $e');
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
                  Icons.volume_up_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alarm Sound',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (_isPlaying)
                  TextButton.icon(
                    onPressed: _stopCurrentSound,
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_alarmSounds.values.map((soundInfo) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSoundOption(context, soundInfo),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption(BuildContext context, AlarmSoundInfo soundInfo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.selectedSound == soundInfo.key;
    final isPlaying = _currentlyPlayingSound == soundInfo.key && _isPlaying;

    return Material(
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(12),
      color: isSelected ? soundInfo.color.withValues(alpha: 0.1) : colorScheme.surface,
      child: InkWell(
        onTap: widget.enabled ? () => widget.onSoundChanged(soundInfo.key) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? soundInfo.color : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? soundInfo.color.withValues(alpha: 0.2) : soundInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  soundInfo.icon,
                  color: isSelected ? soundInfo.color : soundInfo.color.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soundInfo.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? soundInfo.color : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      soundInfo.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                          ? soundInfo.color.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showPreview) ...[
                const SizedBox(width: 8),
                if (isPlaying)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: soundInfo.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(soundInfo.color),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: widget.enabled ? () => _playSound(soundInfo.key) : null,
                    icon: Icon(
                      Icons.play_arrow,
                      color: isSelected ? soundInfo.color : colorScheme.primary,
                    ),
                    tooltip: 'Preview sound',
                    style: IconButton.styleFrom(
                      backgroundColor: isSelected
                        ? soundInfo.color.withValues(alpha: 0.1)
                        : colorScheme.primaryContainer.withValues(alpha: 0.3),
                    ),
                  ),
              ],
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: soundInfo.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information about an alarm sound option
class AlarmSoundInfo {
  final String key;
  final String displayName;
  final String description;
  final String assetPath;
  final IconData icon;
  final Color color;

  const AlarmSoundInfo({
    required this.key,
    required this.displayName,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.color,
  });
}

/// Extension to get alarm sound info by key
extension AlarmSoundExtension on String {
  AlarmSoundInfo? get alarmSoundInfo {
    const sounds = {
      'gentle': AlarmSoundInfo(
        key: 'gentle',
        displayName: 'Gentle Chime',
        description: 'Soft, peaceful chime sound',
        assetPath: 'assets/sounds/gentle_alarm.mp3',
        icon: Icons.music_note_outlined,
        color: Colors.green,
      ),
      'urgent': AlarmSoundInfo(
        key: 'urgent',
        displayName: 'Urgent Alert',
        description: 'Strong, attention-grabbing alarm',
        assetPath: 'assets/sounds/urgent_alarm.mp3',
        icon: Icons.warning_amber_outlined,
        color: Colors.red,
      ),
      'chime': AlarmSoundInfo(
        key: 'chime',
        displayName: 'Peaceful Chime',
        description: 'Calming bell-like chime',
        assetPath: 'assets/sounds/chime_alarm.mp3',
        icon: Icons.notifications_outlined,
        color: Colors.blue,
      ),
    };
    return sounds[this];
  }

  static List<AlarmSoundInfo> get allSounds => [
    'gentle'.alarmSoundInfo!,
    'urgent'.alarmSoundInfo!,
    'chime'.alarmSoundInfo!,
  ];
}