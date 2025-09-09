# HealthBox Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-09-09

## Active Technologies
- Flutter 3.16+ with Dart 3.2+ (001-build-a-mobile)
- Riverpod for state management (001-build-a-mobile)
- Drift (SQLite) with SQLCipher encryption (001-build-a-mobile)
- Material 3 design system (001-build-a-mobile)
- flutter_local_notifications for reminders (001-build-a-mobile)
- Google Drive API for optional sync (001-build-a-mobile)

## Project Structure
```
lib/
├── data/
│   ├── models/          # Drift entities and domain models
│   ├── repositories/    # Data access layer
│   └── database/        # Database setup and migrations
├── features/
│   ├── profiles/        # Family member profile management
│   ├── medical_records/ # CRUD operations for medical data
│   ├── reminders/       # Medication and appointment notifications
│   ├── sync/           # Google Drive synchronization
│   └── export/         # Data export and emergency cards
├── shared/
│   ├── providers/      # Riverpod providers
│   ├── widgets/        # Reusable UI components
│   └── utils/          # Helper functions and constants
└── main.dart

test/
├── unit/               # Unit tests for business logic
├── widget/             # Widget tests for UI components
└── integration/        # Integration tests for user stories
```

## Commands
```bash
# Setup project
flutter pub get
dart run build_runner build

# Run tests
flutter test
flutter test integration_test/

# Build app
flutter build apk --release
flutter build ios --release

# Generate code
dart run build_runner build --delete-conflicting-outputs
```

## Code Style
- Follow standard Flutter/Dart conventions
- Use Riverpod providers for state management
- Implement TDD with failing tests first
- All database operations through Drift DAOs
- Material 3 design patterns for UI
- Offline-first architecture with sync as add-on

## Constitutional Requirements
- Privacy-first: No central servers, optional encrypted sync only
- Offline-first: Core functionality works without internet
- Test-driven: All features require tests before implementation
- Encrypted storage: SQLCipher for all medical data
- Modular libraries: Each feature as separate library

## Recent Changes
- 001-build-a-mobile: Added Flutter medical data management app with offline encryption

<!-- MANUAL ADDITIONS START -->
## Additional Instructions

- Please run flutter analyze frequently to catch bugs before they appear.
- Do not include Claude's name in the git commit message in any way.
- Always make sure all the services, components and other things that you have implemented are being used in our actual UI and app, that they are not in limbo.
<!-- MANUAL ADDITIONS END -->