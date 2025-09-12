import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:health_box/features/profiles/services/profile_service.dart';
import 'package:health_box/data/repositories/profile_dao.dart';
import 'package:health_box/data/models/family_member_profile.dart';

import 'profile_service_test.mocks.dart';

@GenerateMocks([ProfileDao])
void main() {
  late ProfileService profileService;
  late MockProfileDao mockProfileDao;

  setUp(() {
    mockProfileDao = MockProfileDao();
    profileService = ProfileService(mockProfileDao);
  });

  group('ProfileService', () {
    const testProfile = FamilyMemberProfile(
      id: 1,
      name: 'John Doe',
      dateOfBirth: '1990-01-01',
      gender: 'Male',
      bloodType: 'O+',
      phoneNumber: '+1234567890',
      email: 'john.doe@example.com',
      emergencyContact: 'Jane Doe',
      emergencyPhone: '+1234567891',
      notes: 'Test notes',
      isActive: true,
      createdAt: '2025-01-01T00:00:00.000Z',
      updatedAt: '2025-01-01T00:00:00.000Z',
    );

    group('createProfile', () {
      test('should create profile successfully', () async {
        // Arrange
        when(mockProfileDao.insertProfile(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await profileService.createProfile(
          name: testProfile.name,
          dateOfBirth: testProfile.dateOfBirth!,
          gender: testProfile.gender,
          bloodType: testProfile.bloodType,
          phoneNumber: testProfile.phoneNumber,
          email: testProfile.email,
          emergencyContact: testProfile.emergencyContact,
          emergencyPhone: testProfile.emergencyPhone,
          notes: testProfile.notes,
        );

        // Assert
        expect(result, equals(1));
        verify(mockProfileDao.insertProfile(any)).called(1);
      });

      test('should throw exception when dao throws', () async {
        // Arrange
        when(mockProfileDao.insertProfile(any))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => profileService.createProfile(
            name: testProfile.name,
            dateOfBirth: testProfile.dateOfBirth!,
            gender: testProfile.gender,
          ),
          throwsException,
        );
      });
    });

    group('getProfile', () {
      test('should return profile when found', () async {
        // Arrange
        when(mockProfileDao.getProfileById(1))
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await profileService.getProfile(1);

        // Assert
        expect(result, equals(testProfile));
        verify(mockProfileDao.getProfileById(1)).called(1);
      });

      test('should return null when profile not found', () async {
        // Arrange
        when(mockProfileDao.getProfileById(1))
            .thenAnswer((_) async => null);

        // Act
        final result = await profileService.getProfile(1);

        // Assert
        expect(result, isNull);
        verify(mockProfileDao.getProfileById(1)).called(1);
      });
    });

    group('getAllProfiles', () {
      test('should return all profiles', () async {
        // Arrange
        final profiles = [testProfile];
        when(mockProfileDao.getAllProfiles())
            .thenAnswer((_) async => profiles);

        // Act
        final result = await profileService.getAllProfiles();

        // Assert
        expect(result, equals(profiles));
        verify(mockProfileDao.getAllProfiles()).called(1);
      });

      test('should return empty list when no profiles exist', () async {
        // Arrange
        when(mockProfileDao.getAllProfiles())
            .thenAnswer((_) async => <FamilyMemberProfile>[]);

        // Act
        final result = await profileService.getAllProfiles();

        // Assert
        expect(result, isEmpty);
        verify(mockProfileDao.getAllProfiles()).called(1);
      });
    });

    group('updateProfile', () {
      test('should update profile successfully', () async {
        // Arrange
        final updatedProfile = testProfile.copyWith(name: 'Jane Doe');
        when(mockProfileDao.updateProfile(updatedProfile))
            .thenAnswer((_) async => true);

        // Act
        final result = await profileService.updateProfile(updatedProfile);

        // Assert
        expect(result, isTrue);
        verify(mockProfileDao.updateProfile(updatedProfile)).called(1);
      });

      test('should return false when update fails', () async {
        // Arrange
        when(mockProfileDao.updateProfile(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await profileService.updateProfile(testProfile);

        // Assert
        expect(result, isFalse);
        verify(mockProfileDao.updateProfile(testProfile)).called(1);
      });
    });

    group('deleteProfile', () {
      test('should delete profile successfully', () async {
        // Arrange
        when(mockProfileDao.deleteProfile(1))
            .thenAnswer((_) async => true);

        // Act
        final result = await profileService.deleteProfile(1);

        // Assert
        expect(result, isTrue);
        verify(mockProfileDao.deleteProfile(1)).called(1);
      });

      test('should return false when delete fails', () async {
        // Arrange
        when(mockProfileDao.deleteProfile(1))
            .thenAnswer((_) async => false);

        // Act
        final result = await profileService.deleteProfile(1);

        // Assert
        expect(result, isFalse);
        verify(mockProfileDao.deleteProfile(1)).called(1);
      });
    });

    group('getActiveProfiles', () {
      test('should return only active profiles', () async {
        // Arrange
        final activeProfiles = [testProfile];
        when(mockProfileDao.getActiveProfiles())
            .thenAnswer((_) async => activeProfiles);

        // Act
        final result = await profileService.getActiveProfiles();

        // Assert
        expect(result, equals(activeProfiles));
        verify(mockProfileDao.getActiveProfiles()).called(1);
      });
    });

    group('searchProfiles', () {
      test('should return matching profiles', () async {
        // Arrange
        final matchingProfiles = [testProfile];
        when(mockProfileDao.searchProfiles('John'))
            .thenAnswer((_) async => matchingProfiles);

        // Act
        final result = await profileService.searchProfiles('John');

        // Assert
        expect(result, equals(matchingProfiles));
        verify(mockProfileDao.searchProfiles('John')).called(1);
      });

      test('should return empty list when no matches found', () async {
        // Arrange
        when(mockProfileDao.searchProfiles('NonExistent'))
            .thenAnswer((_) async => <FamilyMemberProfile>[]);

        // Act
        final result = await profileService.searchProfiles('NonExistent');

        // Assert
        expect(result, isEmpty);
        verify(mockProfileDao.searchProfiles('NonExistent')).called(1);
      });
    });
  });
}