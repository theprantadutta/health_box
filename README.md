# Health Box 📱💊

A secure, offline-first Flutter mobile application for managing your family's medical information with privacy and convenience.

## ✨ Features

### 🔐 Security & Privacy
- **SQLCipher Encryption**: All medical data encrypted locally
- **Offline-First**: Core functionality works without internet
- **No Central Servers**: Your data stays on your device
- **Optional Google Drive Sync**: Encrypted cloud backup (optional)

### 👨‍👩‍👧‍👦 Family Management
- **Multi-Profile Support**: Manage multiple family members
- **Comprehensive Medical Records**: Prescriptions, medications, lab reports, vaccinations
- **Emergency Cards**: Quick access to critical medical information
- **Family Analytics**: Track health trends and vitals

### ⏰ Smart Reminders
- **Medication Reminders**: Never miss a dose
- **Appointment Notifications**: Stay on schedule
- **Lab Test Alerts**: Track recurring tests
- **Vaccination Reminders**: Keep immunizations up to date
- **Flexible Scheduling**: Daily, weekly, monthly frequencies

### 🎨 Modern UI/UX
- **Material 3 Design**: Clean, modern interface
- **Accessibility Features**: High contrast, large text, reduced animations
- **Responsive Layout**: Optimized for all screen sizes
- **Dark/Light Themes**: System-aware theme switching
- **Intuitive Navigation**: Bottom navigation with smooth transitions

### 📊 Data Management
- **Import/Export**: JSON format for data portability
- **Backup & Restore**: Local and cloud backup options
- **OCR Scanning**: Extract text from medical documents
- **Search & Filter**: Quickly find records by date, type, or content
- **Data Analytics**: Visualize health trends over time

## 🛠️ Technical Stack

- **Flutter 3.16+** with Dart 3.2+
- **Riverpod** for state management
- **Drift (SQLite)** with SQLCipher encryption
- **Material 3** design system
- **flutter_local_notifications** for reminders
- **Google Drive API** for optional sync
- **SharedPreferences** for app settings

## 📁 Project Structure

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
│   ├── export/         # Data export and emergency cards
│   ├── analytics/      # Health tracking and charts
│   └── ocr/            # Document scanning and text extraction
├── shared/
│   ├── providers/      # Riverpod providers
│   ├── widgets/        # Reusable UI components
│   ├── navigation/     # App routing
│   └── theme/          # Material 3 theming
└── screens/            # Main app screens

test/
├── unit/               # Unit tests for business logic
├── widget/             # Widget tests for UI components
└── integration/        # Integration tests for user stories
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16+
- Dart SDK 3.2+
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/health_box.git
   cd health_box
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Setup project
flutter pub get
dart run build_runner build

# Run tests
flutter test
flutter test integration_test/

# Code analysis
flutter analyze

# Build app
flutter build apk --release
flutter build ios --release

# Generate code (after model changes)
dart run build_runner build --delete-conflicting-outputs
```

## 📱 Screenshots & Demo

*(Screenshots will be added as the app development progresses)*

## 🎯 Key Components

### Onboarding System
- **Persistent Settings**: Uses SharedPreferences to show onboarding only once
- **Privacy Education**: Explains data handling and security features
- **Feature Walkthrough**: Interactive introduction to app capabilities

### Reminders System
- **Tabbed Interface**: Active reminders, history, and statistics
- **Smart Filtering**: Filter by type, active status, and date ranges
- **Visual Indicators**: Color-coded reminder types and status badges
- **Quick Actions**: Snooze, complete, edit, and delete reminders

### Settings Management
- **7 Major Sections**: Profile, preferences, accessibility, data, privacy, backup, support
- **Accessibility Options**: High contrast, large text, reduced animations
- **Data Tools**: Export, import, emergency cards, database optimization
- **Advanced Features**: Debug mode, onboarding reset, data clearing

## 🧪 Testing

The app includes comprehensive testing:

- **Unit Tests**: Business logic and service layer testing
- **Widget Tests**: UI component testing with mocking
- **Integration Tests**: End-to-end user journey testing

Run tests with:
```bash
flutter test                    # Unit and widget tests
flutter test integration_test/  # Integration tests
```

## 🔒 Security Features

- **Local Encryption**: SQLCipher for database encryption
- **No Data Collection**: No analytics or telemetry
- **Privacy by Design**: Data never leaves device unless explicitly synced
- **Secure Sync**: End-to-end encryption for Google Drive backups

## 🌐 Platform Support

- ✅ **Android** (Primary target)
- ✅ **iOS** (Secondary target)
- 🔄 **Web** (Future consideration)
- 🔄 **Desktop** (Future consideration)

## 📋 Roadmap

- [x] Core medical record management
- [x] Family profile system
- [x] Reminders and notifications
- [x] Data export/import
- [x] Google Drive sync
- [x] OCR document scanning
- [x] Emergency cards
- [x] Analytics and charts
- [x] Accessibility features
- [ ] Medication interaction checker
- [ ] Health trend predictions
- [ ] Doctor appointment booking
- [ ] Prescription refill reminders
- [ ] Multi-language support

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, please open an issue on GitHub or contact the development team.

---

**Health Box** - Secure, Private, Family-Focused Medical Management 🏥✨
