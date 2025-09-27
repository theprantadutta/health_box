import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../data/models/notification_settings.dart';

/// Widget for selecting notification sounds
class SoundPickerWidget extends StatefulWidget {
  final String currentSound;
  final ValueChanged<String> onSoundChanged;

  const SoundPickerWidget({
    super.key,
    required this.currentSound,
    required this.onSoundChanged,
  });

  @override
  State<SoundPickerWidget> createState() => _SoundPickerWidgetState();
}

class _SoundPickerWidgetState extends State<SoundPickerWidget> {
  String? _customSoundPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sound',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildSoundOptions(),
        if (widget.currentSound == NotificationSounds.custom) ...[
          const SizedBox(height: 12),
          _buildCustomSoundPicker(),
        ],
      ],
    );
  }

  Widget _buildSoundOptions() {
    return Card(
      child: Column(
        children: NotificationSounds.allSounds.map((soundName) {
          return RadioListTile<String>(
            title: Text(NotificationSounds.getDisplayName(soundName)),
            value: soundName,
            groupValue: widget.currentSound,
            onChanged: (value) {
              if (value != null) {
                widget.onSoundChanged(value);
              }
            },
            secondary: soundName != NotificationSounds.custom
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _playSound(soundName),
                    tooltip: 'Play sound',
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomSoundPicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Sound',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (_customSoundPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.audiotrack,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFileName(_customSoundPath!),
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _playCustomSound(_customSoundPath!),
                      tooltip: 'Play sound',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _customSoundPath = null;
                      }),
                      tooltip: 'Remove sound',
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickCustomSound,
                icon: const Icon(Icons.file_upload),
                label: const Text('Select Sound File'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomSound() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _customSoundPath = file.path;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick sound file: $e');
    }
  }

  void _playSound(String soundName) {
    // TODO: Implement sound playing functionality
    // This would use a sound player library to play the notification sound
    _showInfoSnackBar('Playing ${NotificationSounds.getDisplayName(soundName)}');
  }

  void _playCustomSound(String soundPath) {
    // TODO: Implement custom sound playing functionality
    _showInfoSnackBar('Playing custom sound');
  }

  String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}