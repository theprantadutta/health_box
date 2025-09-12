import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Health Box'**
  String get appTitle;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Profiles tab label
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// Medical Records tab label
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// Reminders tab label
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Placeholder text for search field
  ///
  /// In en, this message translates to:
  /// **'Search medical records...'**
  String get searchHint;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Date of birth field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Blood type field label
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// Emergency contact field label
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// Prescriptions label
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// Medications label
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// Lab reports label
  ///
  /// In en, this message translates to:
  /// **'Lab Reports'**
  String get labReports;

  /// Vaccinations label
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinations;

  /// Allergies label
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// Chronic conditions label
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get chronicConditions;

  /// Upcoming reminders section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reminders'**
  String get upcomingReminders;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Message shown when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Try again button label
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Welcome message on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Health Box'**
  String get welcome;

  /// Description on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Securely manage your family\'s medical data with offline-first privacy and optional encrypted sync.'**
  String get onboardingDescription;

  /// Get started button label
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Create profile button label
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// Edit profile button label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Delete profile button label
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// Confirmation message for delete action
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Import button label
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Sync button label
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Backup button label
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Emergency card label
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get emergencyCard;

  /// Generate emergency card button label
  ///
  /// In en, this message translates to:
  /// **'Generate Emergency Card'**
  String get generateEmergencyCard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
