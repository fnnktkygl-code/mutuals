import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/fit_preference.dart';
import '../models/member_group.dart';
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
  // nextMemberId removed as we use UUIDs
  bool get notificationsOn;
  bool get hasFamily;
  SyncService get syncService;
  List<MemberGroup> get groupList;
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
    const uuid = Uuid();
    final owner = Member(
      id: uuid.v4(),
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
      groupIds: groupList.isNotEmpty ? [groupList.first.id] : [],
    );
    memberList = [owner];
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
      // If it's the "Moi" profile, it should be shared (ownerId=null).
      // If it's a contact added by me, it should be private to me (ownerId=currentUser.uid).
      // Note: 'isOwner' means "Is this the profile OF the user?".
      // So if isOwner=true, ownerId=null.
      // If isOwner=false, ownerId=authService.currentUser?.uid.
      ownerId: member.isOwner ? null : authService.currentUser?.uid,
    );
    memberList.add(newMember);
    await saveMembersToStorage();

    if (hasFamily) {
      syncService.syncMember(newMember);
    }

    if (notificationsOn && newMember.birthday != null) {
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
      await saveMembersToStorage();

      if (hasFamily) {
        syncService.syncMember(updated);
      }

      if (notificationsOn && member.birthday != null) {
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

    if (hasFamily) {
      syncService.deleteMemberRemote(id);
    }

    await NotificationService().cancelNotification(id);
    notifyListeners();
  }

  /// Get a member by ID
  Member? getMember(String id) {
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
