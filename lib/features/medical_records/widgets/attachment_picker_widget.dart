import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AttachmentPickerWidget extends StatefulWidget {
  final Function(List<File>) onFilesSelected;
  final List<String> allowedExtensions;
  final int maxFiles;
  final int maxFileSizeBytes;

  const AttachmentPickerWidget({
    super.key,
    required this.onFilesSelected,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    this.maxFiles = 10,
    this.maxFileSizeBytes = 50 * 1024 * 1024, // 50MB default
  });

  @override
  State<AttachmentPickerWidget> createState() => _AttachmentPickerWidgetState();
}

class _AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Files'),
                  ),
                ),
              ],
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: _getFileIcon(file),
                      title: Text(
                        _getFileName(file),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(_getFileSize(file)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFile(index),
                      ),
                    ),
                  );
                },
              ),
            ],
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tip: Files will be uploaded when you save the record',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final List<File> newFiles = images.map((image) => File(image.path)).toList();
        _addFiles(newFiles);
      }
    } catch (e) {
      _showError('Failed to pick images from gallery: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        _addFiles([File(image.path)]);
      }
    } catch (e) {
      _showError('Failed to take picture: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        final List<File> newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        _addFiles(newFiles);
      }
    } catch (e) {
      _showError('Failed to pick files: $e');
    }
  }

  void _addFiles(List<File> newFiles) {
    setState(() {
      for (final file in newFiles) {
        // Check file size
        final sizeBytes = file.lengthSync();
        if (sizeBytes > widget.maxFileSizeBytes) {
          _showError('File ${_getFileName(file)} is too large (${_getFileSize(file)}). Maximum size is ${_formatBytes(widget.maxFileSizeBytes)}.');
          continue;
        }

        // Check max files limit
        if (_selectedFiles.length >= widget.maxFiles) {
          _showError('Maximum ${widget.maxFiles} files allowed.');
          break;
        }

        // Add file if not already selected
        if (!_selectedFiles.any((existing) => existing.path == file.path)) {
          _selectedFiles.add(file);
        }
      }
    });

    widget.onFilesSelected(_selectedFiles);
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  Widget _getFileIcon(File file) {
    final String extension = _getFileExtension(file).toLowerCase();

    switch (extension) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.blue);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  String _getFileExtension(File file) {
    final fileName = _getFileName(file);
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(lastDot + 1) : '';
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    return _formatBytes(bytes);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}