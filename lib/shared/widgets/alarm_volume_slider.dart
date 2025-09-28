import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Widget for adjusting alarm volume with real-time audio preview
/// Provides a smooth slider with volume indicators and preview functionality
class AlarmVolumeSlider extends StatefulWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final String? previewSound;
  final bool enabled;
  final bool showPreview;
  final String? label;

  const AlarmVolumeSlider({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
    this.previewSound = 'gentle',
    this.enabled = true,
    this.showPreview = true,
    this.label,
  });

  @override
  State<AlarmVolumeSlider> createState() => _AlarmVolumeSliderState();
}

class _AlarmVolumeSliderState extends State<AlarmVolumeSlider>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Map<String, String> _soundPaths = {
    'gentle': 'sounds/gentle_alarm.mp3',
    'urgent': 'sounds/urgent_alarm.mp3',
    'chime': 'sounds/chime_alarm.mp3',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _stopPreview();
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playPreview() async {
    if (!widget.showPreview || widget.previewSound == null) return;

    try {
      await _stopPreview();

      setState(() {
        _isPlaying = true;
      });

      _pulseController.repeat(reverse: true);

      final soundPath = _soundPaths[widget.previewSound!];
      if (soundPath == null) return;

      await _audioPlayer.setVolume(widget.volume);
      await _audioPlayer.play(AssetSource(soundPath));

      // Provide haptic feedback
      if (widget.enabled) {
        HapticFeedback.lightImpact();
      }

      // Stop after 2 seconds to prevent annoyance
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _stopPreview();
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          _stopPreview();
        }
      });

    } catch (e) {
      debugPrint('Error playing volume preview: $e');
      _stopPreview();
    }
  }

  Future<void> _stopPreview() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        _pulseController.stop();
        _pulseController.reset();
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      debugPrint('Error stopping volume preview: $e');
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
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isPlaying ? _pulseAnimation.value : 1.0,
                      child: Icon(
                        _getVolumeIcon(widget.volume),
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label ?? 'Alarm Volume',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (widget.showPreview && widget.previewSound != null) ...[
                  if (_isPlaying)
                    TextButton.icon(
                      onPressed: _stopPreview,
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Stop'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: widget.enabled ? _playPreview : null,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Test'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.3),
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                      valueIndicatorColor: colorScheme.primaryContainer,
                      valueIndicatorTextStyle: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: widget.volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(widget.volume * 100).round()}%',
                      onChanged: widget.enabled ? (value) {
                        widget.onVolumeChanged(value);
                        // Provide subtle haptic feedback when sliding
                        HapticFeedback.selectionClick();
                      } : null,
                      onChangeEnd: (value) {
                        // Play a quick preview when user finishes adjusting
                        if (widget.showPreview && widget.enabled) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _playPreview();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.volume_up,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVolumeIndicator(
                  context,
                  label: 'Silent',
                  isActive: widget.volume == 0.0,
                ),
                _buildVolumeIndicator(
                  context,
                  label: 'Low',
                  isActive: widget.volume > 0.0 && widget.volume <= 0.3,
                ),
                _buildVolumeIndicator(
                  context,
                  label: 'Medium',
                  isActive: widget.volume > 0.3 && widget.volume <= 0.7,
                ),
                _buildVolumeIndicator(
                  context,
                  label: 'High',
                  isActive: widget.volume > 0.7,
                ),
              ],
            ),
            if (widget.volume == 0.0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Silent alarms may not wake you up effectively',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeIndicator(
    BuildContext context, {
    required String label,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
            ? colorScheme.primary.withValues(alpha: 0.5)
            : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isActive
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  IconData _getVolumeIcon(double volume) {
    if (volume == 0.0) {
      return Icons.volume_off_outlined;
    } else if (volume <= 0.3) {
      return Icons.volume_down_outlined;
    } else if (volume <= 0.7) {
      return Icons.volume_up_outlined;
    } else {
      return Icons.volume_up;
    }
  }
}

/// Quick preset buttons for common volume levels
class VolumePresetButtons extends StatelessWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final bool enabled;

  const VolumePresetButtons({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildPresetButton(
          context,
          label: 'Low',
          volume: 0.3,
          icon: Icons.volume_down_outlined,
        ),
        _buildPresetButton(
          context,
          label: 'Medium',
          volume: 0.6,
          icon: Icons.volume_up_outlined,
        ),
        _buildPresetButton(
          context,
          label: 'High',
          volume: 0.9,
          icon: Icons.volume_up,
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context, {
    required String label,
    required double volume,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = (currentVolume - volume).abs() < 0.1;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: enabled ? (selected) {
        if (selected) {
          onVolumeChanged(volume);
          HapticFeedback.lightImpact();
        }
      } : null,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }
}