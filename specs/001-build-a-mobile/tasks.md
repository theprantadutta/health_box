# Tasks: HealthBox Mobile Medical Data Manager

**Input**: Design documents from `G:/MyProjects/health_box/specs/001-build-a-mobile/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓), quickstart.md (✓)

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Phase 3.1: Flutter Project Setup

- [x] **T001** Initialize Flutter project with latest version 3.16+ at repository root `G:/MyProjects/health_box/`
- [x] **T002** Configure `pubspec.yaml` with core dependencies: `riverpod`, `drift`, `sqlite3_flutter_libs`, `sqlcipher_flutter_libs`, `material_color_utilities`
- [x] **T003** [P] Configure `analysis_options.yaml` with strict linting rules and Flutter conventions
- [x] **T004** [P] Set up `build.yaml` for Drift code generation with SQLCipher support
- [x] **T005** Create project structure: `lib/data/`, `lib/features/`, `lib/shared/`, `test/unit/`, `test/widget/`, `integration_test/`

## Phase 3.2: Database & Core Models Setup

- [x] **T006** Set up Drift database configuration with SQLCipher encryption in `lib/data/database/app_database.dart`
- [x] **T007** [P] Create FamilyMemberProfile Drift table in `lib/data/models/family_member_profile.dart`
- [x] **T008** [P] Create MedicalRecord base Drift table in `lib/data/models/medical_record.dart`
- [x] **T009** [P] Create Prescription Drift table extending MedicalRecord in `lib/data/models/prescription.dart`
- [x] **T010** [P] Create LabReport Drift table extending MedicalRecord in `lib/data/models/lab_report.dart`
- [x] **T011** [P] Create Medication Drift table extending MedicalRecord in `lib/data/models/medication.dart`
- [x] **T012** [P] Create Vaccination Drift table extending MedicalRecord in `lib/data/models/vaccination.dart`
- [ ] **T013** [P] Create Allergy Drift table extending MedicalRecord in `lib/data/models/allergy.dart`
- [ ] **T014** [P] Create ChronicCondition Drift table extending MedicalRecord in `lib/data/models/chronic_condition.dart`
- [ ] **T015** [P] Create Tag Drift table in `lib/data/models/tag.dart`
- [ ] **T016** [P] Create Attachment Drift table in `lib/data/models/attachment.dart`
- [ ] **T017** [P] Create Reminder Drift table in `lib/data/models/reminder.dart`
- [ ] **T018** [P] Create EmergencyCard Drift table in `lib/data/models/emergency_card.dart`

## Phase 3.3: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.4
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Contract Tests
- [ ] **T019** [P] Contract test ProfileServiceContract in `test/contract/profile_service_contract_test.dart`
- [ ] **T020** [P] Contract test MedicalRecordsServiceContract in `test/contract/medical_records_service_contract_test.dart`
- [ ] **T021** [P] Contract test ReminderServiceContract in `test/contract/reminder_service_contract_test.dart`
- [ ] **T022** [P] Contract test SyncServiceContract in `test/contract/sync_service_contract_test.dart`
- [ ] **T023** [P] Contract test ExportServiceContract in `test/contract/export_service_contract_test.dart`
- [ ] **T024** [P] Contract test StorageServiceContract in `test/contract/storage_service_contract_test.dart`

### Integration Tests (User Stories)
- [ ] **T025** [P] Integration test: First-time user onboarding in `integration_test/user_onboarding_test.dart`
- [ ] **T026** [P] Integration test: Multiple family profiles management in `integration_test/family_profiles_test.dart`
- [ ] **T027** [P] Integration test: Offline functionality in `integration_test/offline_functionality_test.dart`
- [ ] **T028** [P] Integration test: Medication reminders in `integration_test/medication_reminders_test.dart`
- [ ] **T029** [P] Integration test: Data export and sharing in `integration_test/data_export_test.dart`
- [ ] **T030** [P] Integration test: Google Drive sync in `integration_test/google_drive_sync_test.dart`
- [ ] **T031** [P] Integration test: Large dataset performance in `integration_test/performance_test.dart`

## Phase 3.4: Core Service Implementation (ONLY after tests are failing)

### Data Access Layer (DAOs)
- [ ] **T032** [P] Implement ProfileDao in `lib/data/repositories/profile_dao.dart`
- [ ] **T033** [P] Implement MedicalRecordDao in `lib/data/repositories/medical_record_dao.dart`
- [ ] **T034** [P] Implement ReminderDao in `lib/data/repositories/reminder_dao.dart`
- [ ] **T035** [P] Implement TagDao in `lib/data/repositories/tag_dao.dart`
- [ ] **T036** [P] Implement AttachmentDao in `lib/data/repositories/attachment_dao.dart`

### Service Layer Implementation
- [ ] **T037** Implement ProfileService with CRUD operations in `lib/features/profiles/services/profile_service.dart`
- [ ] **T038** Implement MedicalRecordsService with search and filtering in `lib/features/medical_records/services/medical_records_service.dart`
- [ ] **T039** Implement PrescriptionService in `lib/features/medical_records/services/prescription_service.dart`
- [ ] **T040** Implement MedicationService with reminder integration in `lib/features/medical_records/services/medication_service.dart`
- [ ] **T041** Implement LabReportService in `lib/features/medical_records/services/lab_report_service.dart`
- [ ] **T042** [P] Implement ReminderService in `lib/features/reminders/services/reminder_service.dart`
- [ ] **T043** [P] Implement NotificationService in `lib/features/reminders/services/notification_service.dart`
- [ ] **T044** [P] Implement StorageService with encryption in `lib/data/services/storage_service.dart`
- [ ] **T045** [P] Implement FileStorageService for attachments in `lib/data/services/file_storage_service.dart`

## Phase 3.5: Riverpod State Management

- [ ] **T046** [P] Create ProfileProvider and ProfileNotifier in `lib/features/profiles/providers/profile_provider.dart`
- [ ] **T047** [P] Create MedicalRecordsProvider in `lib/features/medical_records/providers/medical_records_provider.dart`
- [ ] **T048** [P] Create ReminderProvider in `lib/features/reminders/providers/reminder_provider.dart`
- [ ] **T049** [P] Create DatabaseProvider for app database instance in `lib/shared/providers/database_provider.dart`
- [ ] **T050** [P] Create SettingsProvider for app configuration in `lib/shared/providers/settings_provider.dart`

## Phase 3.6: UI Screens & Widgets

### Profile Management UI
- [ ] **T051** Create ProfileListScreen with multi-profile switching in `lib/features/profiles/screens/profile_list_screen.dart`
- [ ] **T052** Create ProfileFormScreen for add/edit in `lib/features/profiles/screens/profile_form_screen.dart`
- [ ] **T053** [P] Create ProfileCard widget in `lib/features/profiles/widgets/profile_card.dart`

### Medical Records UI
- [ ] **T054** Create MedicalRecordListScreen with search/filter in `lib/features/medical_records/screens/medical_record_list_screen.dart`
- [ ] **T055** Create MedicalRecordDetailScreen in `lib/features/medical_records/screens/medical_record_detail_screen.dart`
- [ ] **T056** Create PrescriptionFormScreen in `lib/features/medical_records/screens/prescription_form_screen.dart`
- [ ] **T057** Create MedicationFormScreen with reminder setup in `lib/features/medical_records/screens/medication_form_screen.dart`
- [ ] **T058** Create LabReportFormScreen in `lib/features/medical_records/screens/lab_report_form_screen.dart`
- [ ] **T059** [P] Create MedicalRecordCard widget in `lib/features/medical_records/widgets/medical_record_card.dart`
- [ ] **T060** [P] Create SearchFilterWidget in `lib/features/medical_records/widgets/search_filter_widget.dart`

### Dashboard & Home UI
- [ ] **T061** Create DashboardScreen with recent activity and upcoming reminders in `lib/features/dashboard/screens/dashboard_screen.dart`
- [ ] **T062** [P] Create UpcomingRemindersWidget in `lib/features/dashboard/widgets/upcoming_reminders_widget.dart`
- [ ] **T063** [P] Create RecentActivityWidget in `lib/features/dashboard/widgets/recent_activity_widget.dart`
- [ ] **T064** [P] Create QuickActionsWidget in `lib/features/dashboard/widgets/quick_actions_widget.dart`

## Phase 3.7: File Management & Attachments

- [ ] **T065** [P] Add `file_picker` and `image_picker` dependencies to `pubspec.yaml`
- [ ] **T066** Implement AttachmentService for file operations in `lib/shared/services/attachment_service.dart`
- [ ] **T067** Create AttachmentFormWidget for file selection in `lib/shared/widgets/attachment_form_widget.dart`
- [ ] **T068** [P] Create AttachmentViewWidget for displaying files in `lib/shared/widgets/attachment_view_widget.dart`

## Phase 3.8: Tagging & Search System

- [ ] **T069** Implement TagService with CRUD operations in `lib/shared/services/tag_service.dart`
- [ ] **T070** [P] Create TagManagementScreen in `lib/shared/screens/tag_management_screen.dart`
- [ ] **T071** [P] Create TagSelectorWidget in `lib/shared/widgets/tag_selector_widget.dart`
- [ ] **T072** Implement SearchService with full-text search in `lib/shared/services/search_service.dart`

## Phase 3.9: Reminder System Integration

- [ ] **T073** Configure flutter_local_notifications with proper permissions in `lib/features/reminders/services/notification_config.dart`
- [ ] **T074** Create ReminderScheduler for notification timing in `lib/features/reminders/services/reminder_scheduler.dart`
- [ ] **T075** [P] Create ReminderFormWidget in `lib/features/reminders/widgets/reminder_form_widget.dart`
- [ ] **T076** [P] Create ActiveRemindersWidget in `lib/features/reminders/widgets/active_reminders_widget.dart`

## Phase 3.10: Emergency Card Generator

- [ ] **T077** [P] Add `pdf` and `qr_flutter` dependencies to `pubspec.yaml`
- [ ] **T078** Implement EmergencyCardService in `lib/features/export/services/emergency_card_service.dart`
- [ ] **T079** Create EmergencyCardScreen for configuration in `lib/features/export/screens/emergency_card_screen.dart`
- [ ] **T080** [P] Create EmergencyCardPreviewWidget in `lib/features/export/widgets/emergency_card_preview_widget.dart`

## Phase 3.11: Google Drive Sync Implementation

- [ ] **T081** [P] Add `google_sign_in`, `googleapis`, and encryption dependencies to `pubspec.yaml`
- [ ] **T082** Implement GoogleDriveService with authentication in `lib/features/sync/services/google_drive_service.dart`
- [ ] **T083** Implement SyncService with conflict resolution in `lib/features/sync/services/sync_service.dart`
- [ ] **T084** Create SyncSettingsScreen in `lib/features/sync/screens/sync_settings_screen.dart`
- [ ] **T085** [P] Create SyncStatusWidget in `lib/features/sync/widgets/sync_status_widget.dart`

## Phase 3.12: Export/Import System

- [ ] **T086** [P] Add `archive` dependency for ZIP support to `pubspec.yaml`
- [ ] **T087** Implement ExportService with multiple formats in `lib/features/export/services/export_service.dart`
- [ ] **T088** Implement ImportService with validation in `lib/features/export/services/import_service.dart`
- [ ] **T089** Create ExportScreen with format selection in `lib/features/export/screens/export_screen.dart`
- [ ] **T090** Create ImportScreen with file validation in `lib/features/export/screens/import_screen.dart`

## Phase 3.13: OCR Support (Optional)

- [ ] **T091** [P] Add `google_ml_kit` dependency to `pubspec.yaml`
- [ ] **T092** [P] Implement OCRService for prescription scanning in `lib/features/ocr/services/ocr_service.dart`
- [ ] **T093** [P] Create OCRScanScreen in `lib/features/ocr/screens/ocr_scan_screen.dart`

## Phase 3.14: Analytics & Graphs

- [ ] **T094** [P] Add `fl_chart` dependency for graphs to `pubspec.yaml`
- [ ] **T095** [P] Implement AnalyticsService for vitals tracking in `lib/features/analytics/services/analytics_service.dart`
- [ ] **T096** [P] Create VitalsTrackingScreen in `lib/features/analytics/screens/vitals_tracking_screen.dart`
- [ ] **T097** [P] Create VitalsChartWidget in `lib/features/analytics/widgets/vitals_chart_widget.dart`

## Phase 3.15: UI Polish & Accessibility

- [ ] **T098** Implement theme system with light/dark mode in `lib/shared/theme/app_theme.dart`
- [ ] **T099** [P] Add internationalization with `flutter_intl` in `lib/l10n/`
- [ ] **T100** [P] Implement semantic labels for accessibility in all major widgets
- [ ] **T101** [P] Create responsive layout helpers in `lib/shared/utils/responsive_utils.dart`
- [ ] **T102** [P] Add Material 3 dynamic colors and theming in `lib/shared/theme/material3_theme.dart`

## Phase 3.16: App Integration & Navigation

- [ ] **T103** Set up app routing with `go_router` in `lib/shared/navigation/app_router.dart`
- [ ] **T104** Create MainAppScreen with bottom navigation in `lib/screens/main_app_screen.dart`
- [ ] **T105** Create OnboardingScreen for first-time users in `lib/screens/onboarding_screen.dart`
- [ ] **T106** Implement app lifecycle management in `lib/shared/services/app_lifecycle_service.dart`

## Phase 3.17: Testing & Error Handling

- [ ] **T107** [P] Create error handling system in `lib/shared/error/error_handler.dart`
- [ ] **T108** [P] Implement logging service in `lib/shared/services/logging_service.dart`
- [ ] **T109** [P] Add offline state management in `lib/shared/providers/connectivity_provider.dart`
- [ ] **T110** [P] Create unit tests for all services in `test/unit/services/`
- [ ] **T111** [P] Create widget tests for all major screens in `test/widget/`

## Phase 3.18: Build & Release Preparation

- [ ] **T112** Configure Android build with ProGuard rules in `android/app/build.gradle`
- [ ] **T113** Configure iOS build with proper entitlements in `ios/Runner/Info.plist`
- [ ] **T114** [P] Set up app icons and splash screens for both platforms
- [ ] **T115** [P] Configure app store metadata and screenshots
- [ ] **T116** Run `flutter analyze` and fix all issues
- [ ] **T117** Run all tests and ensure 100% pass rate
- [ ] **T118** [P] Test offline functionality thoroughly
- [ ] **T119** [P] Test on multiple device sizes and orientations
- [ ] **T120** Generate release builds and test installation

## Dependencies

### Critical Path
- Setup (T001-T005) → Models (T006-T018) → Tests (T019-T031) → Services (T032-T045) → UI (T046-T064)
- Tests MUST fail before implementation begins
- Database setup (T006) blocks all model creation (T007-T018)
- Services (T032-T045) block UI implementation (T046-T064)

### Parallel Opportunities
- All model creation tasks (T007-T018) can run in parallel
- All contract tests (T019-T024) can run in parallel
- All integration tests (T025-T031) can run in parallel
- All DAO implementations (T032-T036) can run in parallel
- Many provider and widget tasks can run in parallel

## Parallel Execution Examples

```bash
# Phase 3.2 - Database Models (run together):
Task: "Create FamilyMemberProfile Drift table in lib/data/models/family_member_profile.dart"
Task: "Create MedicalRecord base Drift table in lib/data/models/medical_record.dart"
Task: "Create Prescription Drift table in lib/data/models/prescription.dart"
Task: "Create LabReport Drift table in lib/data/models/lab_report.dart"
# ... (all T007-T018)

# Phase 3.3 - Contract Tests (run together):
Task: "Contract test ProfileServiceContract in test/contract/profile_service_contract_test.dart"
Task: "Contract test MedicalRecordsServiceContract in test/contract/medical_records_service_contract_test.dart"
# ... (all T019-T024)

# Phase 3.3 - Integration Tests (run together):
Task: "Integration test: First-time user onboarding in integration_test/user_onboarding_test.dart"
Task: "Integration test: Multiple family profiles management in integration_test/family_profiles_test.dart"
# ... (all T025-T031)
```

## Notes
- All tests must be written first and must fail (TDD approach)
- Run `flutter analyze` frequently to catch issues early
- Verify offline functionality works at each major milestone
- Use real database for integration tests (no mocks)
- Each task should result in a working, testable component
- Maintain constitutional requirements: privacy-first, offline-first, encrypted storage

## Task Validation Checklist
- [x] All 6 contracts have corresponding test tasks (T019-T024)
- [x] All 12 entities have model creation tasks (T007-T018)
- [x] All 7 user stories have integration tests (T025-T031)
- [x] Tests come before implementation in every phase
- [x] Parallel tasks operate on different files
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] TDD methodology enforced with failing tests first

**Tasks Status**: ✅ COMPLETE - 120 executable tasks generated
**Ready for implementation**: All tasks are specific, ordered, and immediately executable