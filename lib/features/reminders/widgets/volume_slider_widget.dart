import 'package:flutter/material.dart';

/// Widget for adjusting notification volume
class VolumeSliderWidget extends StatefulWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final bool showMuteButton;

  const VolumeSliderWidget({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
    this.showMuteButton = true,
  });

  @override
  State<VolumeSliderWidget> createState() => _VolumeSliderWidgetState();
}

class _VolumeSliderWidgetState extends State<VolumeSliderWidget> {
  late double _currentVolume;
  double _previousVolume = 0.8;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.volume;
    if (_currentVolume > 0) {
      _previousVolume = _currentVolume;
    }
  }

  @override
  void didUpdateWidget(VolumeSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume != widget.volume) {
      _currentVolume = widget.volume;
      if (_currentVolume > 0) {
        _previousVolume = _currentVolume;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Volume',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              '${(_currentVolume * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.showMuteButton)
              IconButton(
                onPressed: _toggleMute,
                icon: Icon(_getVolumeIcon()),
                tooltip: _currentVolume == 0 ? 'Unmute' : 'Mute',
              ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: _currentVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_currentVolume * 100).round()}%',
                  onChanged: (value) {
                    setState(() {
                      _currentVolume = value;
                      if (value > 0) {
                        _previousVolume = value;
                      }
                    });
                  },
                  onChangeEnd: (value) {
                    widget.onVolumeChanged(value);
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: _testVolume,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Test volume',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildVolumePreset('Low', 0.3),
            _buildVolumePreset('Medium', 0.6),
            _buildVolumePreset('High', 0.9),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumePreset(String label, double volume) {
    final theme = Theme.of(context);
    final isSelected = (_currentVolume - volume).abs() < 0.05;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentVolume = volume;
          _previousVolume = volume;
        });
        widget.onVolumeChanged(volume);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  IconData _getVolumeIcon() {
    if (_currentVolume == 0) {
      return Icons.volume_off;
    } else if (_currentVolume < 0.3) {
      return Icons.volume_mute;
    } else if (_currentVolume < 0.7) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  void _toggleMute() {
    setState(() {
      if (_currentVolume == 0) {
        // Unmute - restore previous volume
        _currentVolume = _previousVolume;
      } else {
        // Mute - save current volume and set to 0
        _previousVolume = _currentVolume;
        _currentVolume = 0;
      }
    });
    widget.onVolumeChanged(_currentVolume);
  }

  void _testVolume() {
    // TODO: Implement volume testing
    // This would play a test sound at the current volume level
    final volumePercent = (_currentVolume * 100).round();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing volume at $volumePercent%'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}