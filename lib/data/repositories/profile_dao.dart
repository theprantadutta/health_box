import 'package:drift/drift.dart';
import '../database/app_database.dart';

class ProfileDao {
  final AppDatabase _database;

  ProfileDao(this._database);

  Future<List<FamilyMemberProfile>> getAllProfiles() async {
    try {
      return await (_database.select(_database.familyMemberProfiles)
            ..where((profile) => profile.isActive.equals(true))
            ..orderBy([
              (profile) => OrderingTerm(expression: profile.firstName),
              (profile) => OrderingTerm(expression: profile.lastName),
            ]))
          .get();
    } catch (e) {
      throw Exception('Failed to get profiles from database: $e');
    }
  }

  Future<FamilyMemberProfile?> getProfileById(String id) async {
    try {
      return await (_database.select(_database.familyMemberProfiles)..where(
            (profile) => profile.id.equals(id) & profile.isActive.equals(true),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw Exception('Failed to get profile by ID from database: $e');
    }
  }

  Future<List<FamilyMemberProfile>> getProfilesByName(String searchTerm) async {
    final searchPattern = '%${searchTerm.toLowerCase()}%';
    return await (_database.select(_database.familyMemberProfiles)
          ..where(
            (profile) =>
                profile.isActive.equals(true) &
                (profile.firstName.lower().like(searchPattern) |
                    profile.lastName.lower().like(searchPattern) |
                    profile.middleName.lower().like(searchPattern)),
          )
          ..orderBy([
            (profile) => OrderingTerm(expression: profile.firstName),
            (profile) => OrderingTerm(expression: profile.lastName),
          ]))
        .get();
  }

  Future<String> createProfile(FamilyMemberProfilesCompanion profile) async {
    try {
      await _database.into(_database.familyMemberProfiles).insert(profile);
      return profile.id.value;
    } catch (e) {
      throw Exception('Failed to create profile in database: $e');
    }
  }

  Future<bool> updateProfile(
    String id,
    FamilyMemberProfilesCompanion profile,
  ) async {
    final updatedProfile = profile.copyWith(updatedAt: Value(DateTime.now()));

    final rowsAffected = await (_database.update(
      _database.familyMemberProfiles,
    )..where((p) => p.id.equals(id))).write(updatedProfile);

    return rowsAffected > 0;
  }

  Future<bool> deleteProfile(String id) async {
    final rowsAffected =
        await (_database.update(
          _database.familyMemberProfiles,
        )..where((p) => p.id.equals(id))).write(
          FamilyMemberProfilesCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }

  Future<bool> permanentlyDeleteProfile(String id) async {
    final rowsAffected = await (_database.delete(
      _database.familyMemberProfiles,
    )..where((p) => p.id.equals(id))).go();

    return rowsAffected > 0;
  }

  Future<int> getActiveProfileCount() async {
    final query = _database.selectOnly(_database.familyMemberProfiles)
      ..addColumns([_database.familyMemberProfiles.id.count()])
      ..where(_database.familyMemberProfiles.isActive.equals(true));

    final result = await query.getSingle();
    return result.read(_database.familyMemberProfiles.id.count()) ?? 0;
  }

  Future<List<FamilyMemberProfile>> getProfilesByGender(String gender) async {
    return await (_database.select(_database.familyMemberProfiles)
          ..where(
            (profile) =>
                profile.isActive.equals(true) & profile.gender.equals(gender),
          )
          ..orderBy([
            (profile) => OrderingTerm(expression: profile.firstName),
            (profile) => OrderingTerm(expression: profile.lastName),
          ]))
        .get();
  }

  Future<List<FamilyMemberProfile>> getProfilesByAgeRange(
    int minAge,
    int maxAge,
  ) async {
    final now = DateTime.now();
    final maxBirthDate = DateTime(now.year - minAge, now.month, now.day);
    final minBirthDate = DateTime(now.year - maxAge - 1, now.month, now.day);

    return await (_database.select(_database.familyMemberProfiles)
          ..where(
            (profile) =>
                profile.isActive.equals(true) &
                profile.dateOfBirth.isBetweenValues(minBirthDate, maxBirthDate),
          )
          ..orderBy([
            (profile) => OrderingTerm(
              expression: profile.dateOfBirth,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<FamilyMemberProfile>> getRecentlyUpdatedProfiles({
    int limit = 10,
  }) async {
    return await (_database.select(_database.familyMemberProfiles)
          ..where((profile) => profile.isActive.equals(true))
          ..orderBy([
            (profile) => OrderingTerm(
              expression: profile.updatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  Future<bool> profileExists(String id) async {
    final count =
        await (_database.selectOnly(_database.familyMemberProfiles)
              ..addColumns([_database.familyMemberProfiles.id.count()])
              ..where(
                _database.familyMemberProfiles.id.equals(id) &
                    _database.familyMemberProfiles.isActive.equals(true),
              ))
            .getSingle();

    return (count.read(_database.familyMemberProfiles.id.count()) ?? 0) > 0;
  }

  Future<List<FamilyMemberProfile>> getProfilesWithEmergencyContact() async {
    return await (_database.select(_database.familyMemberProfiles)..where(
          (profile) =>
              profile.isActive.equals(true) &
              profile.emergencyContact.isNotNull(),
        ))
        .get();
  }

  Future<List<FamilyMemberProfile>> getProfilesWithInsurance() async {
    return await (_database.select(_database.familyMemberProfiles)..where(
          (profile) =>
              profile.isActive.equals(true) & profile.insuranceInfo.isNotNull(),
        ))
        .get();
  }

  Stream<List<FamilyMemberProfile>> watchAllProfiles() {
    return (_database.select(_database.familyMemberProfiles)
          ..where((profile) => profile.isActive.equals(true))
          ..orderBy([
            (profile) => OrderingTerm(expression: profile.firstName),
            (profile) => OrderingTerm(expression: profile.lastName),
          ]))
        .watch();
  }

  Stream<FamilyMemberProfile?> watchProfile(String id) {
    return (_database.select(_database.familyMemberProfiles)..where(
          (profile) => profile.id.equals(id) & profile.isActive.equals(true),
        ))
        .watchSingleOrNull();
  }
}
