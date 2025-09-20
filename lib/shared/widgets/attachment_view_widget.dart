import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/database/app_database.dart';
import '../services/attachment_service.dart';
import '../utils/file_utils.dart';

class AttachmentViewWidget extends StatefulWidget {
  final List<Attachment> attachments;
  final bool showDescription;
  final bool allowDelete;
  final ValueChanged<Attachment>? onAttachmentTap;
  final ValueChanged<Attachment>? onAttachmentDelete;
  final bool isCompact;

  const AttachmentViewWidget({
    super.key,
    required this.attachments,
    this.showDescription = true,
    this.allowDelete = false,
    this.onAttachmentTap,
    this.onAttachmentDelete,
    this.isCompact = false,
  });

  @override
  State<AttachmentViewWidget> createState() => _AttachmentViewWidgetState();
}

class _AttachmentViewWidgetState extends State<AttachmentViewWidget> {
  final AttachmentService _attachmentService = AttachmentService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.attachments.isEmpty) {
      return _buildEmptyState(theme);
    }

    if (widget.isCompact) {
      return _buildCompactView(theme);
    }

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
                  'Attachments (${widget.attachments.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTotalSize(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.attachments.map(
              (attachment) => _buildAttachmentItem(theme, attachment),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.attach_file,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('No attachments', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'This record has no attached files',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.attachments
          .map((attachment) => _buildCompactAttachmentChip(theme, attachment))
          .toList(),
    );
  }

  Widget _buildCompactAttachmentChip(ThemeData theme, Attachment attachment) {
    return ActionChip(
      avatar: Icon(
        _getFileTypeIcon(attachment.fileType),
        size: 18,
        color: _getFileTypeColor(attachment.fileType),
      ),
      label: Text(
        attachment.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => widget.onAttachmentTap?.call(attachment),
    );
  }

  Widget _buildAttachmentItem(ThemeData theme, Attachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onAttachmentTap?.call(attachment),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // File type icon and preview
                  _buildFilePreview(theme, attachment),
                  const SizedBox(width: 12),

                  // File details
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              FileUtils.getReadableFileType(
                                attachment.fileName,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getFileTypeColor(attachment.fileType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              FileUtils.formatFileSize(attachment.fileSize),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Added ${_formatDate(attachment.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _buildAttachmentActions(theme, attachment),
                ],
              ),

              // Description
              if (widget.showDescription &&
                  attachment.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    attachment.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(ThemeData theme, Attachment attachment) {
    if (attachment.fileType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 48,
          height: 48,
          child: FutureBuilder<File>(
            future: _attachmentService.getAttachmentFile(attachment),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.existsSync()) {
                return Image.file(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFileIcon(theme, attachment);
                  },
                );
              }
              return _buildFileIcon(theme, attachment);
            },
          ),
        ),
      );
    }

    return _buildFileIcon(theme, attachment);
  }

  Widget _buildFileIcon(ThemeData theme, Attachment attachment) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getFileTypeColor(attachment.fileType).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getFileTypeColor(attachment.fileType).withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        _getFileTypeIcon(attachment.fileType),
        color: _getFileTypeColor(attachment.fileType),
        size: 24,
      ),
    );
  }

  Widget _buildAttachmentActions(ThemeData theme, Attachment attachment) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAttachmentAction(value, attachment),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 8),
              Text('View'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [Icon(Icons.share), SizedBox(width: 8), Text('Share')],
          ),
        ),
        if (widget.allowDelete)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  void _handleAttachmentAction(String action, Attachment attachment) {
    switch (action) {
      case 'view':
        widget.onAttachmentTap?.call(attachment);
        break;
      case 'share':
        _shareAttachment(attachment);
        break;
      case 'delete':
        _showDeleteConfirmation(attachment);
        break;
    }
  }

  void _showDeleteConfirmation(Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text(
          'Are you sure you want to delete "${attachment.fileName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAttachmentDelete?.call(attachment);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAttachment(Attachment attachment) async {
    try {
      if (attachment.filePath.isEmpty) {
        _showMessage('File path not available for sharing');
        return;
      }

      final file = File(attachment.filePath);
      if (!await file.exists()) {
        _showMessage('File not found: ${attachment.fileName}');
        return;
      }

      // For now, show a dialog with file information
      // In a full implementation, this would use share_plus package
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Share ${attachment.fileName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: ${attachment.fileName}'),
              Text('Type: ${attachment.fileType}'),
              Text('Size: ${attachment.fileSize} bytes'),
              const SizedBox(height: 16),
              const Text(
                'Sharing functionality would export this file to other apps.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showMessage('Share functionality requires share_plus package');
              },
              child: const Text('Share'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('Error sharing file: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  String _getTotalSize() {
    final totalBytes = widget.attachments.fold<int>(
      0,
      (sum, attachment) => sum + attachment.fileSize,
    );
    return FileUtils.formatFileSize(totalBytes);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
