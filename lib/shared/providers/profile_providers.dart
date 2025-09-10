import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../features/profiles/services/profile_service.dart';

// Service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Basic profile providers
final allProfilesProvider = FutureProvider<List<FamilyMemberProfile>>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getAllProfiles();
});

final profileByIdProvider = FutureProvider.family<FamilyMemberProfile?, String>((ref, profileId) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfileById(profileId);
});

final profilesByGenderProvider = FutureProvider.family<List<FamilyMemberProfile>, String>((ref, gender) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfilesByGender(gender);
});

final activeProfileCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getActiveProfileCount();
});

final profileStatisticsProvider = FutureProvider<ProfileStatistics>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfileStatistics();
});

final searchProfilesProvider = FutureProvider.family<List<FamilyMemberProfile>, String>((ref, searchTerm) async {
  final service = ref.read(profileServiceProvider);
  return service.searchProfiles(searchTerm);
});

// Stream providers for real-time updates
final watchAllProfilesProvider = StreamProvider<List<FamilyMemberProfile>>((ref) {
  final service = ref.read(profileServiceProvider);
  return service.watchAllProfiles();
});

final watchProfileProvider = StreamProvider.family<FamilyMemberProfile?, String>((ref, profileId) {
  final service = ref.read(profileServiceProvider);
  return service.watchProfile(profileId);
});

// Profile management state
class ProfileState {
  final List<FamilyMemberProfile> profiles;
  final FamilyMemberProfile? selectedProfile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profiles = const [],
    this.selectedProfile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    List<FamilyMemberProfile>? profiles,
    FamilyMemberProfile? selectedProfile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());
  
  final Ref ref;

  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final service = ref.read(profileServiceProvider);
      final profiles = await service.getAllProfiles();
      state = state.copyWith(profiles: profiles, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> createProfile(CreateProfileRequest request) async {
    try {
      final service = ref.read(profileServiceProvider);
      await service.createProfile(request);
      
      // Refresh profiles list
      await loadProfiles();
      
      // Invalidate related providers
      ref.invalidate(allProfilesProvider);
      ref.invalidate(activeProfileCountProvider);
      ref.invalidate(profileStatisticsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> updateProfile(String profileId, UpdateProfileRequest request) async {
    try {
      final service = ref.read(profileServiceProvider);
      await service.updateProfile(profileId, request);
      
      // Refresh profiles list
      await loadProfiles();
      
      // Invalidate related providers
      ref.invalidate(allProfilesProvider);
      ref.invalidate(profileStatisticsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final service = ref.read(profileServiceProvider);
      await service.deleteProfile(profileId);
      
      // Clear selected profile if it was deleted
      if (state.selectedProfile?.id == profileId) {
        state = state.copyWith(selectedProfile: null);
      }
      
      // Refresh profiles list
      await loadProfiles();
      
      // Invalidate related providers
      ref.invalidate(allProfilesProvider);
      ref.invalidate(activeProfileCountProvider);
      ref.invalidate(profileStatisticsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  void selectProfile(FamilyMemberProfile? profile) {
    state = state.copyWith(selectedProfile: profile);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

// Utility providers
final profileExistsProvider = FutureProvider.family<bool, String>((ref, profileId) async {
  final service = ref.read(profileServiceProvider);
  return service.profileExists(profileId);
});

final calculateAgeProvider = Provider.family<int, DateTime>((ref, dateOfBirth) {
  final service = ref.read(profileServiceProvider);
  return service.calculateAge(dateOfBirth);
});

final getAgeCategoryProvider = Provider.family<String, DateTime>((ref, dateOfBirth) {
  final service = ref.read(profileServiceProvider);
  return service.getAgeCategory(dateOfBirth);
});