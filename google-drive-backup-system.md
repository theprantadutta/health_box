# Google Drive Backup System Documentation

## Overview

The HealthBox app implements a comprehensive Google Drive backup system that allows users to securely backup their medical data to the cloud. This document provides an in-depth analysis of how the system works.

## Architecture Components

### 1. Google Drive Service (`lib/services/google_drive_service.dart`)

The core service that handles all Google Drive interactions:

- **Authentication**: Uses `google_sign_in` package with scopes for both app data and file access
- **Folder Structure**: Creates a hierarchical folder structure:
  ```
  HealthBox/
  ├── Database Backups/    # SQLite database backups (.db files)
  └── Data Exports/       # JSON exports of structured data
  ```
- **File Operations**: Upload, download, list, and delete operations for both backup types

### 2. Authentication Flow

#### Why Authentication is Necessary

Google Drive backup requires authentication for several reasons:

1. **Security**: Ensures only authorized users can access their medical data
2. **Privacy**: Each user's data is stored in their personal Google Drive
3. **Compliance**: Medical data requires secure, authenticated access
4. **API Access**: Google Drive API requires OAuth2 authentication

#### Authentication Methods

1. **Interactive Sign-in** (`signIn()`):
   - Uses `GoogleSignIn.authenticate()` for new logins
   - Prompts user for consent and account selection
   - Initializes Drive API with proper scopes

2. **Silent Sign-in** (`signInSilently()`):
   - Uses `GoogleSignIn.attemptLightweightAuthentication()`
   - No user interaction required for returning users
   - Falls back to interactive sign-in if failed

### 3. Backup Preference System (`lib/shared/providers/backup_preference_providers.dart`)

Manages user's backup preferences:

- **BackupStrategy Enum**: `localOnly` vs `googleDrive`
- **BackupPreference Class**: Combines enabled status and strategy
- **SharedPreferences Storage**: Persists preferences locally

### 4. Provider Architecture (`lib/features/sync/providers/google_drive_providers.dart`)

#### GoogleDriveAuth Provider
- Manages authentication state
- Handles sign-in/sign-out operations
- Updates sync settings when authentication changes

#### SyncSettings Provider
- Manages Google Drive connection status
- Handles auto-sync preferences
- Stores sync frequency and conflict resolution settings

#### BackupOperations Provider
- Manages backup creation process with progress tracking
- Handles database and data export operations
- Implements retry logic and error handling

## Backup Process Flow

### Database Backup Process

1. **Preparation Phase** (0-10%):
   - Check if Google Drive backup is enabled
   - Ensure user authentication
   - Validate backup preferences

2. **Creation Phase** (10-20%):
   - Create local SQLite database backup
   - Retry logic with exponential backoff
   - Generate timestamped filename

3. **Upload Phase** (20-80%):
   - Upload to Google Drive with progress tracking
   - Chunked upload for large files
   - Real-time progress updates

4. **Finalization Phase** (80-100%):
   - Clean up local backup file
   - Update last sync time
   - Clean up old backups based on retention settings
   - Refresh backup list

### Data Export Process

Similar to database backup but exports structured JSON data containing:
- Family member profiles
- Medical records
- Prescriptions and medications
- Lab reports and vaccinations
- Allergies and chronic conditions
- Reminders and emergency cards

## Error Handling and Recovery

### Authentication Errors
- Automatic retry with silent sign-in
- Fallback to interactive sign-in
- Clear error messages for users

### Network Errors
- Exponential backoff retry logic
- Progress preservation during retries
- Network connectivity checks

### Storage Errors
- Quota checking and reporting
- Cleanup of failed uploads
- User notification for storage issues

## Current Issue Analysis

### Problem: Backup Not Auto-Enabled After Login

**Root Cause**: The authentication flow in `GoogleDriveAuth.signIn()` updates sync settings but doesn't enable backup preferences.

**Current Flow**:
1. User signs in to Google Drive ✓
2. `GoogleDriveAuth.signIn()` calls `syncSettingsProvider.updateGoogleDriveConnected(true)` ✓
3. But backup preferences (`BackupPreference`) remain unchanged ❌
4. Backup creation fails because `BackupPreference.enabled = false` ❌

**Expected Flow**:
1. User signs in to Google Drive ✓
2. Update sync settings ✓
3. **Auto-enable backup with Google Drive strategy** ❌ (Missing)
4. Backup creation succeeds ✓

## Security Considerations

### Data Encryption
- SQLite database uses SQLCipher for at-rest encryption
- Data is encrypted before upload to Google Drive
- No plain-text medical data in cloud storage

### Access Control
- OAuth2 with limited scopes
- User-specific Drive folders
- No shared or public access

### Privacy
- No central servers - direct user-to-Google Drive
- User controls all data deletion
- Offline-first architecture

## File Organization

### Database Backups
- **Format**: SQLite database files (.db)
- **Naming**: `healthbox_database_[timestamp].db`
- **Content**: Complete encrypted database backup
- **Use Case**: Full system restore

### Data Exports
- **Format**: JSON files (.json)
- **Naming**: `healthbox_export_[timestamp].json`
- **Content**: Structured medical data
- **Use Case**: Data portability and migration

## Configuration Options

### Sync Settings
- **Auto Sync**: Enable/disable automatic backups
- **Sync Frequency**: Daily, Weekly, Monthly
- **Conflict Resolution**: Ask user, Use local, Use remote, Merge data
- **WiFi Only**: Restrict sync to WiFi connections
- **Backup Retention**: Number of backups to keep (1-30)

### Performance Optimizations
- Chunked uploads for large files
- Progress tracking with real-time updates
- Efficient folder structure creation
- Connection pooling and reuse

## Future Enhancements

1. **Incremental Backups**: Only backup changed data
2. **Compression**: Reduce backup file sizes
3. **Scheduling**: Background sync with WorkManager
4. **Conflict Resolution**: Automated merge strategies
5. **Multi-cloud Support**: Additional cloud providers