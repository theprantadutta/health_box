import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

// Import all table definitions
import '../models/family_member_profile.dart';
import '../models/medical_record.dart';
import '../models/prescription.dart';
import '../models/lab_report.dart';
import '../models/medication.dart';
import '../models/vaccination.dart';
import '../models/allergy.dart';
import '../models/chronic_condition.dart';
import '../models/tag.dart';
import '../models/attachment.dart';
import '../models/reminder.dart';
import '../models/emergency_card.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  FamilyMemberProfiles,
  MedicalRecords,
  Prescriptions,
  LabReports,
  Medications,
  Vaccinations,
  Allergies,
  ChronicConditions,
  Tags,
  Attachments,
  Reminders,
  EmergencyCards,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  
  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON;');
      
      // Enable WAL mode for better concurrent access
      await customStatement('PRAGMA journal_mode = WAL;');
      
      // Set synchronous to NORMAL for better performance
      await customStatement('PRAGMA synchronous = NORMAL;');
      
      // Set cache size to 10MB
      await customStatement('PRAGMA cache_size = -10000;');
    },
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create indexes for better query performance
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_medical_records_profile_id 
        ON medical_records(profile_id);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_medical_records_record_date 
        ON medical_records(record_date);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_medical_records_is_active 
        ON medical_records(is_active);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_reminders_scheduled_time 
        ON reminders(scheduled_time);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_reminders_is_active 
        ON reminders(is_active);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_attachments_record_id 
        ON attachments(record_id);
      ''');
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      // Initialize SQLCipher libraries
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'health_box.db'));
      
      // Use SQLCipher with encryption
      final database = NativeDatabase.createInBackground(
        file,
        setup: (database) {
          // Set encryption key (in production, this should come from secure storage)
          // For now, using a default key - this should be user-configurable
          const encryptionKey = 'health_box_encryption_key_2024';
          database.execute('PRAGMA key = "$encryptionKey";');
          
          // Verify the database can be opened with this key
          database.execute('PRAGMA cipher_version;');
          
          // Additional security settings
          database.execute('PRAGMA cipher_page_size = 4096;');
          database.execute('PRAGMA kdf_iter = 64000;');
          database.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA256;');
          database.execute('PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA256;');
        },
      );
      
      return database;
    });
  }

  // Helper method to test database connection
  Future<bool> testConnection() async {
    try {
      await customSelect('SELECT 1;').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get database file size
  Future<int> getDatabaseSize() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'health_box.db'));
    
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Helper method to backup database (for export functionality)
  Future<String> backupDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final sourceFile = File(p.join(dbFolder.path, 'health_box.db'));
    final backupFile = File(p.join(
      dbFolder.path,
      'health_box_backup_${DateTime.now().millisecondsSinceEpoch}.db',
    ));
    
    if (await sourceFile.exists()) {
      await sourceFile.copy(backupFile.path);
      return backupFile.path;
    }
    
    throw Exception('Database file not found');
  }

  // Helper method to vacuum database (cleanup)
  Future<void> vacuumDatabase() async {
    await customStatement('VACUUM;');
  }

  // Close database connection
  @override
  Future<void> close() async {
    await super.close();
  }
}