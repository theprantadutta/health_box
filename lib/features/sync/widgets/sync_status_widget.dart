import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

class SyncStatusWidget extends ConsumerStatefulWidget {
  final SyncService? syncService;
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    super.key,
    this.syncService,
    this.showDetails = true,
    this.onTap,
  });

  @override
  ConsumerState<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends ConsumerState<SyncStatusWidget>
    with TickerProviderStateMixin {
  SyncStatus _currentStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  double _progress = 0.0;
  List<SyncConflict> _pendingConflicts = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSyncServiceListeners();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulsing for active states
    if (_isActiveStatus(_currentStatus)) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _setupSyncServiceListeners() {
    if (widget.syncService != null) {
      widget.syncService!.onStatusChanged = (status) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
            _lastSyncTime = widget.syncService!.lastSyncTime;
          });
          _updateAnimations();
        }
      };

      widget.syncService!.onProgressChanged = (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      };

      widget.syncService!.onConflictsDetected = (conflicts) {
        if (mounted) {
          setState(() => _pendingConflicts = conflicts);
        }
      };

      // Initialize with current state
      setState(() {
        _currentStatus = widget.syncService!.currentStatus;
        _lastSyncTime = widget.syncService!.lastSyncTime;
        _pendingConflicts = widget.syncService!.pendingConflicts;
      });
    }
  }

  void _updateAnimations() {
    if (_isActiveStatus(_currentStatus)) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  bool _isActiveStatus(SyncStatus status) {
    return status == SyncStatus.syncing ||
        status == SyncStatus.uploading ||
        status == SyncStatus.downloading ||
        status == SyncStatus.resolving;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (widget.showDetails) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getStatusDescription(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_pendingConflicts.isNotEmpty) _buildConflictsBadge(),
                ],
              ),
              if (widget.showDetails && _isActiveStatus(_currentStatus)) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(),
              ],
              if (widget.showDetails && _lastSyncTime != null) ...[
                const SizedBox(height: 8),
                _buildLastSyncInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final icon = _getStatusIcon();
    final color = _getStatusColor();

    if (_isActiveStatus(_currentStatus)) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(icon, color: color, size: 24),
          );
        },
      );
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _currentStatus == SyncStatus.resolving ? null : _progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getProgressText(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_currentStatus != SyncStatus.resolving)
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildConflictsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${_pendingConflicts.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSyncInfo() {
    final timeAgo = _getTimeAgo(_lastSyncTime!);
    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Last sync: $timeAgo',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case SyncStatus.idle:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.uploading:
        return Icons.cloud_upload;
      case SyncStatus.downloading:
        return Icons.cloud_download;
      case SyncStatus.resolving:
        return Icons.merge_type;
      case SyncStatus.completed:
        return Icons.check_circle;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.noConnection:
        return Icons.cloud_off;
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case SyncStatus.idle:
        return Colors.grey[600]!;
      case SyncStatus.syncing:
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.resolving:
        return Theme.of(context).primaryColor;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.noConnection:
        return Colors.orange;
    }
  }

  String _getStatusTitle() {
    switch (_currentStatus) {
      case SyncStatus.idle:
        return 'Ready to Sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.uploading:
        return 'Uploading...';
      case SyncStatus.downloading:
        return 'Downloading...';
      case SyncStatus.resolving:
        return 'Resolving Conflicts';
      case SyncStatus.completed:
        return 'Sync Complete';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.noConnection:
        return 'No Connection';
    }
  }

  String _getStatusDescription() {
    switch (_currentStatus) {
      case SyncStatus.idle:
        return 'Your data is up to date';
      case SyncStatus.syncing:
        return 'Synchronizing your data...';
      case SyncStatus.uploading:
        return 'Backing up your data to Google Drive';
      case SyncStatus.downloading:
        return 'Retrieving data from Google Drive';
      case SyncStatus.resolving:
        return 'Resolving data conflicts';
      case SyncStatus.completed:
        return 'All changes have been synchronized';
      case SyncStatus.error:
        return 'Failed to sync. Tap to retry.';
      case SyncStatus.noConnection:
        return 'Internet connection required';
    }
  }

  String _getProgressText() {
    switch (_currentStatus) {
      case SyncStatus.syncing:
        return 'Analyzing changes...';
      case SyncStatus.uploading:
        return 'Uploading data...';
      case SyncStatus.downloading:
        return 'Downloading data...';
      case SyncStatus.resolving:
        return 'Resolving conflicts...';
      default:
        return '';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
