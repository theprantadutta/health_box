import 'package:flutter_test/flutter_test.dart';
import 'package:health_box/data/database/app_database.dart';
import '../../specs/001-build-a-mobile/contracts/profile_service_contract.dart';

void main() {
  group('ProfileServiceContract', () {
    late ProfileServiceContract service;
    late AppDatabase database;

    setUpAll(() async {
      // Initialize test database
      database = AppDatabase.instance;
      
      // This will fail until we implement ProfileService
      // service = ProfileService(database);
      throw UnimplementedError('ProfileService not yet implemented - this test MUST fail');
    });

    tearDownAll(() async {
      await database.close();
    });

    group('createProfile', () {
      test('should create profile with valid data and return profile ID', () async {
        final profileId = await service.createProfile(
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );

        expect(profileId, isNotEmpty);
        expect(profileId.length, equals(36)); // UUID length
      });

      test('should create profile with all optional fields', () async {
        final profileId = await service.createProfile(
          firstName: 'Jane',
          lastName: 'Smith',
          middleName: 'Marie',
          dateOfBirth: DateTime(1985, 5, 15),
          gender: 'Female',
          bloodType: 'A+',
          height: 165.0,
          weight: 60.5,
          emergencyContact: '+1234567890',
          insuranceInfo: 'Blue Cross 123456',
          profileImagePath: '/path/to/image.jpg',
        );

        expect(profileId, isNotEmpty);
      });

      test('should throw ValidationException for empty firstName', () async {
        expect(
          () => service.createProfile(
            firstName: '',
            lastName: 'Doe',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'Male',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for empty lastName', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: '',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'Male',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for future dateOfBirth', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: 'Doe',
            dateOfBirth: DateTime.now().add(const Duration(days: 1)),
            gender: 'Male',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for invalid gender', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: 'Doe',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'InvalidGender',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for invalid bloodType', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: 'Doe',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'Male',
            bloodType: 'InvalidType',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for invalid height', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: 'Doe',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'Male',
            height: 500.0, // Too tall
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for invalid weight', () async {
        expect(
          () => service.createProfile(
            firstName: 'John',
            lastName: 'Doe',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'Male',
            weight: 1000.0, // Too heavy
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateProfile', () {
      late String existingProfileId;

      setUp(() async {
        // Create a test profile first
        existingProfileId = await service.createProfile(
          firstName: 'Test',
          lastName: 'User',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );
      });

      test('should update profile with valid data', () async {
        final result = await service.updateProfile(
          profileId: existingProfileId,
          firstName: 'Updated',
          lastName: 'Name',
        );

        expect(result, isTrue);
      });

      test('should throw ProfileNotFoundException for non-existent profile', () async {
        expect(
          () => service.updateProfile(
            profileId: 'non-existent-id',
            firstName: 'Updated',
          ),
          throwsA(isA<ProfileNotFoundException>()),
        );
      });

      test('should throw ValidationException for invalid update data', () async {
        expect(
          () => service.updateProfile(
            profileId: existingProfileId,
            firstName: '', // Empty name
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('getProfile', () {
      late String existingProfileId;

      setUp(() async {
        existingProfileId = await service.createProfile(
          firstName: 'Test',
          lastName: 'User',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );
      });

      test('should return profile for existing ID', () async {
        final profile = await service.getProfile(existingProfileId);

        expect(profile, isNotNull);
        expect(profile!.id, equals(existingProfileId));
        expect(profile.firstName, equals('Test'));
        expect(profile.lastName, equals('User'));
      });

      test('should return null for non-existent ID', () async {
        final profile = await service.getProfile('non-existent-id');
        expect(profile, isNull);
      });
    });

    group('getAllProfiles', () {
      setUp(() async {
        // Create multiple test profiles
        await service.createProfile(
          firstName: 'Profile',
          lastName: 'One',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );
        
        await service.createProfile(
          firstName: 'Profile',
          lastName: 'Two',
          dateOfBirth: DateTime(1985, 5, 15),
          gender: 'Female',
        );
      });

      test('should return all active profiles', () async {
        final profiles = await service.getAllProfiles();

        expect(profiles, hasLength(greaterThanOrEqualTo(2)));
        expect(profiles.every((p) => p.isActive), isTrue);
      });

      test('should not return deleted profiles', () async {
        final initialProfiles = await service.getAllProfiles();
        final profileToDelete = initialProfiles.first.id;

        await service.deleteProfile(profileToDelete);
        final remainingProfiles = await service.getAllProfiles();

        expect(remainingProfiles.length, equals(initialProfiles.length - 1));
        expect(remainingProfiles.any((p) => p.id == profileToDelete), isFalse);
      });
    });

    group('deleteProfile', () {
      late String existingProfileId;

      setUp(() async {
        existingProfileId = await service.createProfile(
          firstName: 'Test',
          lastName: 'User',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );
      });

      test('should soft delete existing profile', () async {
        final result = await service.deleteProfile(existingProfileId);
        expect(result, isTrue);

        // Profile should not appear in getAllProfiles
        final profiles = await service.getAllProfiles();
        expect(profiles.any((p) => p.id == existingProfileId), isFalse);
      });

      test('should throw ProfileNotFoundException for non-existent profile', () async {
        expect(
          () => service.deleteProfile('non-existent-id'),
          throwsA(isA<ProfileNotFoundException>()),
        );
      });
    });

    group('validateProfileData', () {
      test('should return valid result for correct data', () {
        final result = service.validateProfileData(
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should return invalid result with errors for empty firstName', () {
        final result = service.validateProfileData(
          firstName: '',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('First name cannot be empty'));
      });

      test('should return invalid result with errors for empty lastName', () {
        final result = service.validateProfileData(
          firstName: 'John',
          lastName: '',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Last name cannot be empty'));
      });

      test('should return invalid result with errors for future birth date', () {
        final result = service.validateProfileData(
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime.now().add(const Duration(days: 1)),
          gender: 'Male',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Birth date cannot be in the future'));
      });

      test('should return invalid result with errors for invalid gender', () {
        final result = service.validateProfileData(
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'InvalidGender',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Gender must be Male, Female, Other, or Unspecified'));
      });

      test('should return invalid result with multiple errors', () {
        final result = service.validateProfileData(
          firstName: '',
          lastName: '',
          dateOfBirth: DateTime.now().add(const Duration(days: 1)),
          gender: 'InvalidGender',
        );

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(4));
      });

      test('should validate optional fields correctly', () {
        final result = service.validateProfileData(
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Male',
          bloodType: 'InvalidType',
          height: 500.0,
          weight: 1000.0,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Blood type must be valid'));
        expect(result.errors, contains('Height must be between 30 and 300 cm'));
        expect(result.errors, contains('Weight must be between 0.5 and 500 kg'));
      });
    });
  });
}