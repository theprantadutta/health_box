import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/attachment_service.dart';
import '../utils/file_utils.dart';

class AttachmentFormWidget extends StatefulWidget {
  final List<AttachmentResult> initialAttachments;
  final ValueChanged<List<AttachmentResult>> onAttachmentsChanged;
  final int maxFiles;
  final List<String>? allowedExtensions;
  final bool allowImages;
  final bool allowDocuments;
  final int maxFileSizeMB;

  const AttachmentFormWidget({
    super.key,
    this.initialAttachments = const [],
    required this.onAttachmentsChanged,
    this.maxFiles = 10,
    this.allowedExtensions,
    this.allowImages = true,
    this.allowDocuments = true,
    this.maxFileSizeMB = 50,
  });

  @override
  State<AttachmentFormWidget> createState() => _AttachmentFormWidgetState();
}

class _AttachmentFormWidgetState extends State<AttachmentFormWidget> {
  final AttachmentService _attachmentService = AttachmentService();
  List<AttachmentResult> _attachments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Attachments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_attachments.length < widget.maxFiles)
                  PopupMenuButton<String>(
                    onSelected: _handleAttachmentAction,
                    itemBuilder: (context) => [
                      if (widget.allowImages)
                        const PopupMenuItem(
                          value: 'camera',
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt),
                              SizedBox(width: 8),
                              Text('Take Photo'),
                            ],
                          ),
                        ),
                      if (widget.allowImages)
                        const PopupMenuItem(
                          value: 'gallery',
                          child: Row(
                            children: [
                              Icon(Icons.photo_library),
                              SizedBox(width: 8),
                              Text('Choose from Gallery'),
                            ],
                          ),
                        ),
                      if (widget.allowDocuments)
                        const PopupMenuItem(
                          value: 'file',
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file),
                              SizedBox(width: 8),
                              Text('Choose File'),
                            ],
                          ),
                        ),
                    ],
                    child: const Icon(Icons.add_circle),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_attachments.isEmpty)
              _buildEmptyState(theme)
            else
              _buildAttachmentList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('No attachments added', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Add photos, documents, or other files to this record',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentList(ThemeData theme) {
    return Column(
      children: _attachments.asMap().entries.map((entry) {
        final index = entry.key;
        final attachment = entry.value;
        return _buildAttachmentItem(theme, attachment, index);
      }).toList(),
    );
  }

  Widget _buildAttachmentItem(
    ThemeData theme,
    AttachmentResult attachment,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileTypeIcon(attachment.fileType),
            color: _getFileTypeColor(attachment.fileType),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${FileUtils.getReadableFileType(attachment.fileName)} • ${FileUtils.formatFileSize(attachment.fileSize)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: theme.colorScheme.error,
            onPressed: () => _removeAttachment(index),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Colors.blue;
      case 'pdf':
        return Colors.red;
      case 'document':
        return Colors.green;
      case 'video':
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAttachmentAction(String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      AttachmentResult? result;

      switch (action) {
        case 'camera':
          result = await _attachmentService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          break;
        case 'gallery':
          result = await _attachmentService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          break;
        case 'file':
          result = await _attachmentService.pickFile(
            type: widget.allowedExtensions != null
                ? FileType.custom
                : FileType.any,
            allowedExtensions: widget.allowedExtensions,
          );
          break;
      }

      if (result != null) {
        if (_attachmentService.isValidFileSize(
          result.fileSize,
          maxSizeMB: widget.maxFileSizeMB,
        )) {
          setState(() {
            _attachments.add(result!);
          });
          widget.onAttachmentsChanged(_attachments);
        } else {
          _showError('File size exceeds ${widget.maxFileSizeMB}MB limit');
        }
      }
    } catch (e) {
      _showError('Failed to add attachment: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
    widget.onAttachmentsChanged(_attachments);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
