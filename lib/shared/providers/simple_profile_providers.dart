import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../features/profiles/services/profile_service.dart';

// Simple service provider
final simpleProfileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Simple profiles provider that loads all profiles once
final simpleProfilesProvider = FutureProvider<List<FamilyMemberProfile>>((
  ref,
) async {
  final service = ref.read(simpleProfileServiceProvider);
  try {
    return await service.getAllProfiles();
  } catch (e) {
    print('Error loading profiles: $e');
    return <FamilyMemberProfile>[];
  }
});

// Simple selected profile provider
final simpleSelectedProfileProvider = FutureProvider<FamilyMemberProfile?>((
  ref,
) async {
  final profiles = await ref.watch(simpleProfilesProvider.future);

  if (profiles.isEmpty) {
    return null;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final selectedProfileId = prefs.getString('selected_profile_id');

    if (selectedProfileId != null) {
      // Try to find the previously selected profile
      final profile = profiles
          .where((p) => p.id == selectedProfileId)
          .firstOrNull;
      if (profile != null) {
        return profile;
      }
    }

    // Fallback to first profile and save it as selected
    final firstProfile = profiles.first;
    await prefs.setString('selected_profile_id', firstProfile.id);
    return firstProfile;
  } catch (e) {
    print('Error loading selected profile: $e');
    return profiles.isNotEmpty ? profiles.first : null;
  }
});

// Helper provider to set selected profile
final setSelectedProfileProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  return (String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_profile_id', profileId);
      // Invalidate the selected profile provider to refresh
      ref.invalidate(simpleSelectedProfileProvider);
    } catch (e) {
      print('Error setting selected profile: $e');
    }
  };
});
