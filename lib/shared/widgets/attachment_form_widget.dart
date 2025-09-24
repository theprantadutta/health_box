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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                Text(
                  '${_attachments.length}/${widget.maxFiles} files',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_attachments.length < widget.maxFiles)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: _handleAttachmentAction,
                      icon: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                      ),
                      itemBuilder: (context) => [
                        if (widget.allowImages)
                          const PopupMenuItem(
                            value: 'camera',
                            child: Row(
                              children: [
                                Icon(Icons.camera_alt_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Take Photo'),
                              ],
                            ),
                          ),
                        if (widget.allowImages)
                          const PopupMenuItem(
                            value: 'gallery',
                            child: Row(
                              children: [
                                Icon(Icons.photo_library_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Choose from Gallery'),
                              ],
                            ),
                          ),
                        if (widget.allowDocuments)
                          const PopupMenuItem(
                            value: 'file',
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Choose File'),
                              ],
                            ),
                          ),
                      ],
                    ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_file_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No attachments yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos, documents, or files\nto support this medical record',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _previewAttachment(attachment),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getFileTypeColor(attachment.fileType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileTypeIcon(attachment.fileType),
                      color: _getFileTypeColor(attachment.fileType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.fileName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                FileUtils.getReadableFileType(attachment.fileName).toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              FileUtils.formatFileSize(attachment.fileSize),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _removeAttachment(index),
                      tooltip: 'Remove attachment',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  void _previewAttachment(AttachmentResult attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preview for ${attachment.fileName}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Implement file preview functionality
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
