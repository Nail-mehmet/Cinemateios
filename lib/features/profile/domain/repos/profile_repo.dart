
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);

  Future<void> updateProfile(ProfileUser updatedProfile);

  Future<void> toggleFollow(String currentUid, String targetUid);

  Future<List<String>> getUserMovies(String userId, String collectionName);

  // Yeni eklenen engelleme metodları
  Future<void> blockUser(String blockerUid, String blockedUid);

  Future<void> unblockUser(String blockerUid, String blockedUid);

  Future<bool> isBlocked(String blockerUid, String blockedUid);
}
