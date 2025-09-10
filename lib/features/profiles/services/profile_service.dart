import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/profile_dao.dart';

class ProfileService {
  final ProfileDao _profileDao;

  ProfileService({
    ProfileDao? profileDao,
    AppDatabase? database,
  })  : _profileDao = profileDao ?? ProfileDao(database ?? AppDatabase.instance);

  // CRUD Operations
  
  Future<List<FamilyMemberProfile>> getAllProfiles() async {
    try {
      return await _profileDao.getAllProfiles();
    } catch (e) {
      throw ProfileServiceException('Failed to retrieve profiles: ${e.toString()}');
    }
  }

  Future<FamilyMemberProfile?> getProfileById(String id) async {
    try {
      if (id.isEmpty) {
        throw const ProfileServiceException('Profile ID cannot be empty');
      }
      return await _profileDao.getProfileById(id);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to retrieve profile: ${e.toString()}');
    }
  }

  Future<List<FamilyMemberProfile>> searchProfiles(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        return await getAllProfiles();
      }
      return await _profileDao.getProfilesByName(searchTerm);
    } catch (e) {
      throw ProfileServiceException('Failed to search profiles: ${e.toString()}');
    }
  }

  Future<String> createProfile(CreateProfileRequest request) async {
    try {
      _validateCreateProfileRequest(request);
      
      final profileId = 'profile_${DateTime.now().millisecondsSinceEpoch}';
      final profileCompanion = FamilyMemberProfilesCompanion(
        id: Value(profileId),
        firstName: Value(request.firstName.trim()),
        lastName: Value(request.lastName.trim()),
        middleName: Value(request.middleName?.trim()),
        dateOfBirth: Value(request.dateOfBirth),
        gender: Value(request.gender),
        bloodType: Value(request.bloodType),
        height: Value(request.height),
        weight: Value(request.weight),
        emergencyContact: Value(request.emergencyContact?.trim()),
        insuranceInfo: Value(request.insuranceInfo?.trim()),
        profileImagePath: Value(request.profileImagePath?.trim()),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      return await _profileDao.createProfile(profileCompanion);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to create profile: ${e.toString()}');
    }
  }

  Future<bool> updateProfile(String id, UpdateProfileRequest request) async {
    try {
      if (id.isEmpty) {
        throw const ProfileServiceException('Profile ID cannot be empty');
      }

      // Check if profile exists
      final existingProfile = await _profileDao.getProfileById(id);
      if (existingProfile == null) {
        throw const ProfileServiceException('Profile not found');
      }

      _validateUpdateProfileRequest(request);

      final profileCompanion = FamilyMemberProfilesCompanion(
        firstName: request.firstName != null ? Value(request.firstName!.trim()) : const Value.absent(),
        lastName: request.lastName != null ? Value(request.lastName!.trim()) : const Value.absent(),
        middleName: request.middleName != null ? Value(request.middleName?.trim()) : const Value.absent(),
        dateOfBirth: request.dateOfBirth != null ? Value(request.dateOfBirth!) : const Value.absent(),
        gender: request.gender != null ? Value(request.gender!) : const Value.absent(),
        bloodType: request.bloodType != null ? Value(request.bloodType) : const Value.absent(),
        height: request.height != null ? Value(request.height) : const Value.absent(),
        weight: request.weight != null ? Value(request.weight) : const Value.absent(),
        emergencyContact: request.emergencyContact != null ? Value(request.emergencyContact?.trim()) : const Value.absent(),
        insuranceInfo: request.insuranceInfo != null ? Value(request.insuranceInfo?.trim()) : const Value.absent(),
        profileImagePath: request.profileImagePath != null ? Value(request.profileImagePath?.trim()) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      return await _profileDao.updateProfile(id, profileCompanion);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<bool> deleteProfile(String id) async {
    try {
      if (id.isEmpty) {
        throw const ProfileServiceException('Profile ID cannot be empty');
      }

      // Check if profile exists
      final existingProfile = await _profileDao.getProfileById(id);
      if (existingProfile == null) {
        throw const ProfileServiceException('Profile not found');
      }

      return await _profileDao.deleteProfile(id);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to delete profile: ${e.toString()}');
    }
  }

  Future<bool> permanentlyDeleteProfile(String id) async {
    try {
      if (id.isEmpty) {
        throw const ProfileServiceException('Profile ID cannot be empty');
      }

      return await _profileDao.permanentlyDeleteProfile(id);
    } catch (e) {
      throw ProfileServiceException('Failed to permanently delete profile: ${e.toString()}');
    }
  }

  // Advanced Query Operations

  Future<List<FamilyMemberProfile>> getProfilesByGender(String gender) async {
    try {
      if (!_isValidGender(gender)) {
        throw ProfileServiceException('Invalid gender: $gender');
      }
      return await _profileDao.getProfilesByGender(gender);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to retrieve profiles by gender: ${e.toString()}');
    }
  }

  Future<List<FamilyMemberProfile>> getProfilesByAgeRange(int minAge, int maxAge) async {
    try {
      if (minAge < 0 || maxAge < 0 || minAge > maxAge) {
        throw const ProfileServiceException('Invalid age range');
      }
      return await _profileDao.getProfilesByAgeRange(minAge, maxAge);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to retrieve profiles by age range: ${e.toString()}');
    }
  }

  Future<List<FamilyMemberProfile>> getRecentlyUpdatedProfiles({int limit = 10}) async {
    try {
      if (limit <= 0) {
        throw const ProfileServiceException('Limit must be greater than 0');
      }
      return await _profileDao.getRecentlyUpdatedProfiles(limit: limit);
    } catch (e) {
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Failed to retrieve recently updated profiles: ${e.toString()}');
    }
  }

  // Statistics and Analytics

  Future<int> getActiveProfileCount() async {
    try {
      return await _profileDao.getActiveProfileCount();
    } catch (e) {
      throw ProfileServiceException('Failed to retrieve profile count: ${e.toString()}');
    }
  }

  Future<ProfileStatistics> getProfileStatistics() async {
    try {
      final totalProfiles = await _profileDao.getActiveProfileCount();
      final maleProfiles = await _profileDao.getProfilesByGender('Male');
      final femaleProfiles = await _profileDao.getProfilesByGender('Female');
      final otherGenderProfiles = await _profileDao.getProfilesByGender('Other');
      final unspecifiedGenderProfiles = await _profileDao.getProfilesByGender('Unspecified');
      
      final childrenProfiles = await _profileDao.getProfilesByAgeRange(0, 17);
      final adultProfiles = await _profileDao.getProfilesByAgeRange(18, 64);
      final seniorProfiles = await _profileDao.getProfilesByAgeRange(65, 120);
      
      final profilesWithEmergencyContact = await _profileDao.getProfilesWithEmergencyContact();
      final profilesWithInsurance = await _profileDao.getProfilesWithInsurance();

      return ProfileStatistics(
        totalProfiles: totalProfiles,
        maleCount: maleProfiles.length,
        femaleCount: femaleProfiles.length,
        otherGenderCount: otherGenderProfiles.length,
        unspecifiedGenderCount: unspecifiedGenderProfiles.length,
        childrenCount: childrenProfiles.length,
        adultCount: adultProfiles.length,
        seniorCount: seniorProfiles.length,
        profilesWithEmergencyContactCount: profilesWithEmergencyContact.length,
        profilesWithInsuranceCount: profilesWithInsurance.length,
      );
    } catch (e) {
      throw ProfileServiceException('Failed to retrieve profile statistics: ${e.toString()}');
    }
  }

  // Utility Methods

  Future<bool> profileExists(String id) async {
    try {
      if (id.isEmpty) return false;
      return await _profileDao.profileExists(id);
    } catch (e) {
      return false;
    }
  }

  int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String getAgeCategory(DateTime dateOfBirth) {
    final age = calculateAge(dateOfBirth);
    if (age < 13) return 'Child';
    if (age < 20) return 'Teenager';
    if (age < 65) return 'Adult';
    return 'Senior';
  }

  // Stream Operations

  Stream<List<FamilyMemberProfile>> watchAllProfiles() {
    return _profileDao.watchAllProfiles();
  }

  Stream<FamilyMemberProfile?> watchProfile(String id) {
    return _profileDao.watchProfile(id);
  }

  // Validation Methods

  void _validateCreateProfileRequest(CreateProfileRequest request) {
    if (request.firstName.trim().isEmpty) {
      throw const ProfileServiceException('First name cannot be empty');
    }
    if (request.lastName.trim().isEmpty) {
      throw const ProfileServiceException('Last name cannot be empty');
    }
    if (request.firstName.length > 50) {
      throw const ProfileServiceException('First name cannot exceed 50 characters');
    }
    if (request.lastName.length > 50) {
      throw const ProfileServiceException('Last name cannot exceed 50 characters');
    }
    if (request.middleName != null && request.middleName!.length > 50) {
      throw const ProfileServiceException('Middle name cannot exceed 50 characters');
    }
    if (request.dateOfBirth.isAfter(DateTime.now())) {
      throw const ProfileServiceException('Date of birth cannot be in the future');
    }
    if (!_isValidGender(request.gender)) {
      throw ProfileServiceException('Invalid gender: ${request.gender}');
    }
    if (request.bloodType != null && !_isValidBloodType(request.bloodType!)) {
      throw ProfileServiceException('Invalid blood type: ${request.bloodType}');
    }
    if (request.height != null && (request.height! < 30 || request.height! > 300)) {
      throw const ProfileServiceException('Height must be between 30 and 300 cm');
    }
    if (request.weight != null && (request.weight! < 0.5 || request.weight! > 500)) {
      throw const ProfileServiceException('Weight must be between 0.5 and 500 kg');
    }
  }

  void _validateUpdateProfileRequest(UpdateProfileRequest request) {
    if (request.firstName != null && request.firstName!.trim().isEmpty) {
      throw const ProfileServiceException('First name cannot be empty');
    }
    if (request.lastName != null && request.lastName!.trim().isEmpty) {
      throw const ProfileServiceException('Last name cannot be empty');
    }
    if (request.firstName != null && request.firstName!.length > 50) {
      throw const ProfileServiceException('First name cannot exceed 50 characters');
    }
    if (request.lastName != null && request.lastName!.length > 50) {
      throw const ProfileServiceException('Last name cannot exceed 50 characters');
    }
    if (request.middleName != null && request.middleName!.length > 50) {
      throw const ProfileServiceException('Middle name cannot exceed 50 characters');
    }
    if (request.dateOfBirth != null && request.dateOfBirth!.isAfter(DateTime.now())) {
      throw const ProfileServiceException('Date of birth cannot be in the future');
    }
    if (request.gender != null && !_isValidGender(request.gender!)) {
      throw ProfileServiceException('Invalid gender: ${request.gender}');
    }
    if (request.bloodType != null && !_isValidBloodType(request.bloodType!)) {
      throw ProfileServiceException('Invalid blood type: ${request.bloodType}');
    }
    if (request.height != null && (request.height! < 30 || request.height! > 300)) {
      throw const ProfileServiceException('Height must be between 30 and 300 cm');
    }
    if (request.weight != null && (request.weight! < 0.5 || request.weight! > 500)) {
      throw const ProfileServiceException('Weight must be between 0.5 and 500 kg');
    }
  }

  bool _isValidGender(String gender) {
    return ['Male', 'Female', 'Other', 'Unspecified'].contains(gender);
  }

  bool _isValidBloodType(String bloodType) {
    return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'].contains(bloodType);
  }
}

// Data Transfer Objects

class CreateProfileRequest {
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? profileImagePath;

  const CreateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.emergencyContact,
    this.insuranceInfo,
    this.profileImagePath,
  });
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? profileImagePath;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.emergencyContact,
    this.insuranceInfo,
    this.profileImagePath,
  });
}

class ProfileStatistics {
  final int totalProfiles;
  final int maleCount;
  final int femaleCount;
  final int otherGenderCount;
  final int unspecifiedGenderCount;
  final int childrenCount;
  final int adultCount;
  final int seniorCount;
  final int profilesWithEmergencyContactCount;
  final int profilesWithInsuranceCount;

  const ProfileStatistics({
    required this.totalProfiles,
    required this.maleCount,
    required this.femaleCount,
    required this.otherGenderCount,
    required this.unspecifiedGenderCount,
    required this.childrenCount,
    required this.adultCount,
    required this.seniorCount,
    required this.profilesWithEmergencyContactCount,
    required this.profilesWithInsuranceCount,
  });
}

// Exceptions

class ProfileServiceException implements Exception {
  final String message;
  
  const ProfileServiceException(this.message);
  
  @override
  String toString() => 'ProfileServiceException: $message';
}