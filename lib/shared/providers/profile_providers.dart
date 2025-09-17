import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../features/profiles/services/profile_service.dart';

// Service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Basic profile providers
final allProfilesProvider = FutureProvider<List<FamilyMemberProfile>>((
  ref,
) async {
  final service = ref.read(profileServiceProvider);
  return service.getAllProfiles();
});

final profileByIdProvider = FutureProvider.family<FamilyMemberProfile?, String>(
  (ref, profileId) async {
    final service = ref.read(profileServiceProvider);
    return service.getProfileById(profileId);
  },
);

final profilesByGenderProvider =
    FutureProvider.family<List<FamilyMemberProfile>, String>((
      ref,
      gender,
    ) async {
      final service = ref.read(profileServiceProvider);
      return service.getProfilesByGender(gender);
    });

final activeProfileCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getActiveProfileCount();
});

final profileStatisticsProvider = FutureProvider<ProfileStatistics>((
  ref,
) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfileStatistics();
});

final searchProfilesProvider =
    FutureProvider.family<List<FamilyMemberProfile>, String>((
      ref,
      searchTerm,
    ) async {
      final service = ref.read(profileServiceProvider);
      return service.searchProfiles(searchTerm);
    });

// Stream providers for real-time updates
final watchAllProfilesProvider = StreamProvider<List<FamilyMemberProfile>>((
  ref,
) {
  final service = ref.read(profileServiceProvider);
  return service.watchAllProfiles();
});

final watchProfileProvider =
    StreamProvider.family<FamilyMemberProfile?, String>((ref, profileId) {
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
    // Prevent concurrent loading to avoid rebuild loops
    if (state.isLoading) {
      return;
    }

    // Debug logging (can be removed in production)
    // print('ProfileNotifier.loadProfiles() - Starting...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(profileServiceProvider);
      // print('ProfileNotifier.loadProfiles() - Getting all profiles...');
      final profiles = await service.getAllProfiles();
      // print('ProfileNotifier.loadProfiles() - Got ${profiles.length} profiles');
      state = state.copyWith(profiles: profiles, isLoading: false);

      // Auto-select profile if none is selected
      if (state.selectedProfile == null && profiles.isNotEmpty) {
        // print('ProfileNotifier.loadProfiles() - Auto-selecting profile...');
        await _loadSelectedProfile(profiles);
        // print('ProfileNotifier.loadProfiles() - Selected profile: ${state.selectedProfile?.firstName ?? 'null'}');
      } else if (profiles.isEmpty) {
        // print('ProfileNotifier.loadProfiles() - No profiles found');
      } else {
        // print('ProfileNotifier.loadProfiles() - Profile already selected: ${state.selectedProfile?.firstName ?? 'null'}');
      }
      // print('ProfileNotifier.loadProfiles() - Completed successfully');
    } catch (error) {
      // print('ProfileNotifier.loadProfiles() - Error: $error');
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> _loadSelectedProfile(List<FamilyMemberProfile> profiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedProfileId = prefs.getString('selected_profile_id');

      if (selectedProfileId != null) {
        // Try to find the previously selected profile
        final profile = profiles.firstWhere(
          (p) => p.id == selectedProfileId,
          orElse: () => profiles.first, // Fallback to first profile
        );
        state = state.copyWith(selectedProfile: profile);
      } else {
        // No previous selection, select the first profile
        final firstProfile = profiles.first;
        state = state.copyWith(selectedProfile: firstProfile);
        await _saveSelectedProfile(firstProfile.id);
      }
    } catch (e) {
      // If there's any error, just select the first profile
      if (profiles.isNotEmpty) {
        state = state.copyWith(selectedProfile: profiles.first);
      }
    }
  }

  Future<void> _saveSelectedProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_profile_id', profileId);
    } catch (e) {
      // Ignore save errors - not critical
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

  Future<void> updateProfile(
    String profileId,
    UpdateProfileRequest request,
  ) async {
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

  Future<void> selectProfile(FamilyMemberProfile? profile) async {
    state = state.copyWith(selectedProfile: profile);
    if (profile != null) {
      await _saveSelectedProfile(profile.id);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
      return ProfileNotifier(ref);
    });

// Utility providers
final profileExistsProvider = FutureProvider.family<bool, String>((
  ref,
  profileId,
) async {
  final service = ref.read(profileServiceProvider);
  return service.profileExists(profileId);
});

final calculateAgeProvider = Provider.family<int, DateTime>((ref, dateOfBirth) {
  final service = ref.read(profileServiceProvider);
  return service.calculateAge(dateOfBirth);
});

final getAgeCategoryProvider = Provider.family<String, DateTime>((
  ref,
  dateOfBirth,
) {
  final service = ref.read(profileServiceProvider);
  return service.getAgeCategory(dateOfBirth);
});
