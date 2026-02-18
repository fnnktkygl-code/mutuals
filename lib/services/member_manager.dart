import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/fit_preference.dart';
import '../models/family_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';

/// Member CRUD operations, mixed into AppState.
///
/// Abstract accessors bridge to AppState's data fields.
mixin MemberManager on ChangeNotifier {
  // ---- Abstract: host class provides the data ----
  List<Member> get memberList;
  set memberList(List<Member> value);

  bool get notificationsOn;
  // hasFamily implies currentGroupId != null in AppState
  bool get hasFamily;
  String? get currentGroupId; // Needed for sync
  List<Family> get myGroups;
  List<String> getGroupIdsForMember(String memberId);
  
  Member? get currentUserProfile;
  set currentUserProfile(Member? value);

  SyncService get syncService;
  AuthService get authService;

  // ---- Public API ----

  List<Member> get members => memberList;

  /// Initialize with owner profile only (used after onboarding)
  Future<void> initializeOwnerProfile({
    required String ownerName,
    required String avatarType,
    required String avatarValue,
    String? avatarCharacterId,
    String? avatarBackgroundColor,
  }) async {
    // Use Firebase UID as the member ID — this is CRITICAL for consistency.
    // Using uuid.v4() caused ID mismatch: Firestore docs keyed by random UUID,
    // but _ensureCurrentUserInList keyed by Firebase UID → duplicate "Moi".
    final ownerId = authService.currentUser?.uid ?? const Uuid().v4();
    final owner = Member(
      id: ownerId,
      name: ownerName,
      relationship: 'Moi',
      gradient: avatarType == 'gradient' ? avatarValue : 'from-purple-400 to-purple-600',
      avatarType: avatarType,
      avatarValue: avatarValue,
      avatarCharacterId: avatarCharacterId,
      avatarBackgroundColor: avatarBackgroundColor,
      fitPreference: FitPreference.regular,
      isOwner: true,
      lastUpdated: DateTime.now(),
    );
    memberList = [owner];
    currentUserProfile = owner;
    await StorageService.saveUserProfile(owner);
    await saveMembersToStorage();
    await StorageService.setHasOnboarded(true);
    notifyListeners();
  }

  /// Add a new member
  Future<void> addMember(Member member) async {
    const uuid = Uuid();
    final newMember = member.copyWith(
      id: uuid.v4(),
      lastUpdated: DateTime.now(),
      // Logic:
      // If adding "Moi" (isOwner=true), ownerId is null (shared).
      // If adding 'Someone Else' (isOwner=false):
      //   - If I am in a shared group, they are private to me by default? 
      //   - OR shared? 
      //   - Design decision: By default, members added to a group are SHARED in that group?
      //   - Original logic: ownerId = currentUser.uid (Private).
      //   - Let's stick to Private by default for non-owner members, unless we have a "Share this profile" toggle?
      //   - Wait, if I add my child, I want my spouse to see them.
      //   - So default should probably be SHARED (ownerId = null) if we are in a group.
      //   - BUT "Mutuals" app concept: "Private by default" (ownerId=me).
      //   - Let's keep original logic: ownerId = me.
      ownerId: member.isOwner ? null : authService.currentUser?.uid,
    );
    
    memberList.add(newMember);
    await saveMembersToStorage();

    if (hasFamily && currentGroupId != null) {
      if (currentGroupId == 'all') {
         if (newMember.isOwner || newMember.id == authService.currentUser?.uid) {
            // Add "Moi" to ALL groups
            for (final group in myGroups) {
               await syncService.syncMember(group.id, newMember);
            }
         } else if (myGroups.isNotEmpty) {
            // Add other members to the MAIN (first) group by default if in "All" view
            // TODO: In future, prompt user to select group
            await syncService.syncMember(myGroups.first.id, newMember);
         }
      } else {
         await syncService.syncMember(currentGroupId!, newMember);
      }
    }

    if (notificationsOn && newMember.birthday != null && newMember.id != authService.currentUser?.uid) {
      await NotificationService().scheduleBirthdayNotification(
        id: newMember.id,
        name: newMember.name,
        birthday: newMember.birthday!,
      );
    }

    notifyListeners();
  }

  /// Update an existing member
  Future<void> updateMember(Member member) async {
    final index = memberList.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      final updated = member.copyWith(lastUpdated: DateTime.now());
      memberList[index] = updated;
      
      // Detect if this member is "Moi" (may have legacy random UUID)
      final isCurrentUser = member.id == authService.currentUser?.uid
          || (currentUserProfile != null && member.id == currentUserProfile!.id)
          || member.isOwner;

      // Update Cached Profile if it's "Moi"
      if (isCurrentUser && authService.currentUser?.uid != null) {
         // Migrate to Firebase UID if still using legacy random UUID
         final canonicalProfile = member.id == authService.currentUser!.uid
             ? updated
             : updated.copyWith(id: authService.currentUser!.uid);
         currentUserProfile = canonicalProfile;
         await StorageService.saveUserProfile(canonicalProfile);
      }
      
      // Optimistic update for UI responsiveness
      notifyListeners();
      
      await saveMembersToStorage();

      if (hasFamily && currentGroupId != null) {
        if (currentGroupId == 'all') {
           // 1. Resolve which groups this member belongs to
           final groupIds = getGroupIdsForMember(member.id);
           
           // 2. Sync to those groups
           for (final gid in groupIds) {
              await syncService.syncMember(gid, updated);
           }
           
           // 3. Special case: "Moi" should be synced to ALL groups, even if not found in cache (e.g. fresh install)
           if (member.id == authService.currentUser?.uid) {
              for (final group in myGroups) {
                  // Avoid double sync if already covered
                  if (!groupIds.contains(group.id)) {
                      await syncService.syncMember(group.id, updated);
                  }
              }
           }
        } else {
           // Single Group Mode
           await syncService.syncMember(currentGroupId!, updated);

           // If updating "Moi", sync to ALL other groups too to keep avatar consistent
           if (member.id == authService.currentUser?.uid) {
               for (final group in myGroups) {
                   if (group.id != currentGroupId) {
                       await syncService.syncMember(group.id, updated);
                   }
               }
           }
        }
      }

      if (notificationsOn && member.birthday != null && member.id != authService.currentUser?.uid) {
        await NotificationService().scheduleBirthdayNotification(
          id: member.id,
          name: member.name,
          birthday: member.birthday!,
        );
      } else {
        await NotificationService().cancelNotification(member.id);
      }

      notifyListeners();
    }
  }

  /// Delete a member
  Future<void> deleteMember(String id) async {
    memberList.removeWhere((m) => m.id == id);
    await saveMembersToStorage();

    if (hasFamily && currentGroupId != null) {
      if (currentGroupId == 'all') {
          final groupIds = getGroupIdsForMember(id);
          for (final gid in groupIds) {
             await syncService.deleteMemberRemote(gid, id);
          }
      } else {
         await syncService.deleteMemberRemote(currentGroupId!, id);
      }
    }

    await NotificationService().cancelNotification(id);
    notifyListeners();
  }

  /// Get a member by ID
  Member? getMember(String id) {
    // If requesting "Moi", prefer cached profile
    if (authService.currentUser?.uid == id && currentUserProfile != null) {
      return currentUserProfile;
    }

    try {
      return memberList.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save members to local storage
  Future<void> saveMembersToStorage() async {
    await StorageService.saveMembers(memberList);
  }
}
