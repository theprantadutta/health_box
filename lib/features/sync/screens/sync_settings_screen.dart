import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/google_drive_service.dart';
import '../services/sync_service.dart';
import '../widgets/sync_status_widget.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  late final SyncService _syncService;

  bool _isLoading = false;
  bool _autoSyncEnabled = false;
  ConflictResolution _defaultConflictResolution = ConflictResolution.manual;
  int _syncFrequencyHours = 24;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService(googleDriveService: _googleDriveService);
    _loadSettings();
    _attemptSilentSignIn();
  }

  Future<void> _loadSettings() async {
    // In a real app, these would come from SharedPreferences or similar
    setState(() {
      _autoSyncEnabled = false; // Load from preferences
      _defaultConflictResolution =
          ConflictResolution.manual; // Load from preferences
      _syncFrequencyHours = 24; // Load from preferences
    });
  }

  Future<void> _saveSettings() async {
    // In a real app, save these to SharedPreferences or similar
    // await prefs.setBool('auto_sync_enabled', _autoSyncEnabled);
    // await prefs.setInt('default_conflict_resolution', _defaultConflictResolution.index);
    // await prefs.setInt('sync_frequency_hours', _syncFrequencyHours);
  }

  Future<void> _attemptSilentSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _googleDriveService.signInSilently();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await _googleDriveService.signIn();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully signed in as ${_googleDriveService.currentUser?.email}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _googleDriveService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed out'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performManualSync() async {
    if (!_googleDriveService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to Google Drive first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _syncService.performFullSync(
        defaultResolution: _defaultConflictResolution,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result.conflicts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${result.conflicts.length} conflicts need resolution',
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Resolve',
                onPressed: () =>
                    _showConflictResolutionDialog(result.conflicts),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConflictResolutionDialog(List<SyncConflict> conflicts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Conflicts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${conflicts.length} conflicts found:'),
            const SizedBox(height: 8),
            for (final conflict in conflicts.take(3))
              Text('• ${conflict.entityType}: ${conflict.entityId}'),
            if (conflicts.length > 3)
              Text('... and ${conflicts.length - 3} more'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to conflict resolution screen
              Navigator.pushNamed(context, '/sync/conflicts');
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRemoteBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Remote Backup'),
        content: const Text(
          'This will permanently delete your backup from Google Drive. '
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _googleDriveService.deleteBackup();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Backup deleted successfully'
                    : 'Failed to delete backup',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sync Status Widget
          const SyncStatusWidget(),
          const SizedBox(height: 24),

          // Google Drive Account Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Google Drive Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_googleDriveService.isSignedIn) ...[
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(
                        _googleDriveService.currentUser?.displayName ??
                            'Unknown',
                      ),
                      subtitle: Text(
                        _googleDriveService.currentUser?.email ?? 'No email',
                      ),
                      trailing: TextButton(
                        onPressed: _isLoading ? null : _signOut,
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ] else ...[
                    const ListTile(
                      leading: Icon(Icons.account_circle_outlined),
                      title: Text('Not signed in'),
                      subtitle: Text('Sign in to enable Google Drive sync'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Sign In to Google Drive'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sync Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sync Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Auto Sync'),
                    subtitle: const Text(
                      'Automatically sync data when changes are made',
                    ),
                    value: _autoSyncEnabled,
                    onChanged: _googleDriveService.isSignedIn
                        ? (value) {
                            setState(() => _autoSyncEnabled = value);
                            _saveSettings();
                          }
                        : null,
                  ),
                  ListTile(
                    title: const Text('Sync Frequency'),
                    subtitle: Text('Every $_syncFrequencyHours hours'),
                    trailing: DropdownButton<int>(
                      value: _syncFrequencyHours,
                      onChanged:
                          _googleDriveService.isSignedIn && _autoSyncEnabled
                          ? (value) {
                              if (value != null) {
                                setState(() => _syncFrequencyHours = value);
                                _saveSettings();
                              }
                            }
                          : null,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 hour')),
                        DropdownMenuItem(value: 6, child: Text('6 hours')),
                        DropdownMenuItem(value: 12, child: Text('12 hours')),
                        DropdownMenuItem(value: 24, child: Text('24 hours')),
                        DropdownMenuItem(value: 168, child: Text('1 week')),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Default Conflict Resolution'),
                    subtitle: Text(
                      _getConflictResolutionText(_defaultConflictResolution),
                    ),
                    trailing: DropdownButton<ConflictResolution>(
                      value: _defaultConflictResolution,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _defaultConflictResolution = value);
                          _saveSettings();
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ConflictResolution.manual,
                          child: Text('Ask me'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.localWins,
                          child: Text('Local wins'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.remoteWins,
                          child: Text('Remote wins'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.merge,
                          child: Text('Auto merge'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manual Actions Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manual Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _googleDriveService.isSignedIn && !_isLoading
                          ? _performManualSync
                          : null,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Now'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _googleDriveService.isSignedIn && !_isLoading
                          ? () => Navigator.pushNamed(context, '/export')
                          : null,
                      icon: const Icon(Icons.upload),
                      label: const Text('Export Data'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _googleDriveService.isSignedIn && !_isLoading
                          ? () => Navigator.pushNamed(context, '/import')
                          : null,
                      icon: const Icon(Icons.download),
                      label: const Text('Import Data'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Danger Zone Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'These actions cannot be undone. Use with caution.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _googleDriveService.isSignedIn && !_isLoading
                          ? _deleteRemoteBackup
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Remote Backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getConflictResolutionText(ConflictResolution resolution) {
    switch (resolution) {
      case ConflictResolution.manual:
        return 'Ask me what to do';
      case ConflictResolution.localWins:
        return 'Keep local changes';
      case ConflictResolution.remoteWins:
        return 'Use remote changes';
      case ConflictResolution.merge:
        return 'Merge automatically';
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
