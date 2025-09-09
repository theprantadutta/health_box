# HealthBox Constitution

## Core Principles

### I. Privacy-First (NON-NEGOTIABLE)

All medical data belongs entirely to the user. No central servers, no mandatory login, no third-party data sharing. Data remains on-device unless the user explicitly opts for encrypted Google Drive sync. All storage and transfers must be encrypted.

### II. Offline-First

The app must work fully offline at all times. Core features (data entry, search, reminders, emergency cards) cannot depend on internet access. Sync and optional cloud features are strictly add-ons, not requirements.

### III. Simplicity & Accessibility

UI must be clean, intuitive, and accessible to all age groups, including elderly users. Features should follow the principle of least surprise, with clear language and straightforward navigation.

### IV. Reliability & Data Integrity

Data must be stored in an encrypted Drift database with robust backup/restore options. Export/import must ensure no corruption or data loss. Sync mechanisms must never overwrite local data without explicit user confirmation.

### V. Extensibility & Modularity

Every feature should be implemented as a modular component to support future growth (e.g., OCR, wearable integration). Future enhancements must not compromise existing user data or privacy principles.

## Security Requirements

* Encrypted local database (SQLCipher).
* End-to-end encrypted Google Drive sync.
* Optional user-defined vault password for an added layer of security.
* Zero third-party analytics, tracking, or telemetry.

## Development Workflow

* Test-First: All critical features require unit and integration tests before merging.
* Code Reviews: All contributions must be reviewed for compliance with privacy and offline-first principles.
* Documentation: Each feature must have clear documentation and user-facing instructions.
* Accessibility Review: All UI changes must be checked against accessibility guidelines.

## Governance

The Constitution supersedes all other practices. Amendments require explicit documentation, justification, and a migration plan to safeguard user data. Privacy and offline-first principles are non-negotiable.

**Version**: 1.0.0 | **Ratified**: 2025-09-07 | **Last Amended**: 2025-09-07