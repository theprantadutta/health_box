// Profile Service Contract - Family Member Profile Management
// Corresponds to FR-001: System MUST allow users to create and manage multiple family member profiles

import 'shared_models.dart';

abstract class ProfileServiceContract {
  // Create new family member profile
  // Returns: Profile ID on success, throws ValidationException on invalid data
  Future<String> createProfile({
    required String firstName,
    required String lastName,
    String? middleName,
    required DateTime dateOfBirth,
    required String gender,
    String? bloodType,
    double? height,
    double? weight,
    String? emergencyContact,
    String? insuranceInfo,
    String? profileImagePath,
  });

  // Update existing profile
  // Returns: true on success, throws ProfileNotFoundException if not found
  Future<bool> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    String? emergencyContact,
    String? insuranceInfo,
    String? profileImagePath,
  });

  // Get profile by ID
  // Returns: FamilyMemberProfile or null if not found
  Future<FamilyMemberProfile?> getProfile(String profileId);

  // Get all active profiles
  // Returns: List of all family member profiles
  Future<List<FamilyMemberProfile>> getAllProfiles();

  // Soft delete profile (marks as inactive)
  // Returns: true on success, throws ProfileNotFoundException if not found
  Future<bool> deleteProfile(String profileId);

  // Validate profile data
  // Returns: ValidationResult with errors if any
  ValidationResult validateProfileData({
    required String firstName,
    required String lastName,
    String? middleName,
    required DateTime dateOfBirth,
    required String gender,
    String? bloodType,
    double? height,
    double? weight,
  });
}

class ProfileNotFoundException implements Exception {
  final String profileId;
  ProfileNotFoundException(this.profileId);
}