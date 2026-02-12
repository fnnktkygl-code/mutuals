import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/member_group.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';

/// Group CRUD operations, mixed into AppState.
///
/// Abstract accessors bridge to AppState's data fields.
mixin GroupManager on ChangeNotifier {
  // ---- Abstract: host class provides the data ----
  List<MemberGroup> get groupList;
  set groupList(List<MemberGroup> value);
  List<Member> get memberList;
  bool get hasFamily;
  SyncService get syncService;
  AuthService get authService;

  /// Provided by co-mixin (MemberManager).
  Future<void> updateMember(Member member);

  // ---- Public API ----

  List<MemberGroup> get groups => groupList;

  /// Initialize default groups if none exist
  void initializeDefaultGroups() {
    if (groupList.isEmpty) {
      groupList = MemberGroup.createDefaults();
    }
  }

  /// Add a new group
  Future<MemberGroup> addGroup(String name, String icon, String color) async {
    final newGroup = MemberGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      color: color,
      order: groupList.length,
      isDefault: false,
      ownerId: authService.currentUser?.uid,
    );
    groupList.add(newGroup);
    await saveGroupsToStorage();

    if (hasFamily) {
      syncService.syncGroup(newGroup);
    }

    notifyListeners();
    return newGroup;
  }

  /// Update an existing group
  Future<void> updateGroup(String id, MemberGroup updatedGroup) async {
    final index = groupList.indexWhere((g) => g.id == id);
    if (index != -1) {
      groupList[index] = updatedGroup;
      await saveGroupsToStorage();

      if (hasFamily) {
        syncService.syncGroup(updatedGroup);
      }

      notifyListeners();
    }
  }

  /// Delete a group and reassign members
  Future<void> deleteGroup(String id, String? reassignToGroupId) async {
    if (reassignToGroupId != null) {
      for (var member in memberList) {
        if (member.groupIds.contains(id)) {
          final newGroups = List<String>.from(member.groupIds)
            ..remove(id)
            ..add(reassignToGroupId);
          await updateMember(member.copyWith(groupIds: newGroups));
        }
      }
    }

    groupList.removeWhere((g) => g.id == id);
    await saveGroupsToStorage();

    if (hasFamily) {
      syncService.deleteGroupRemote(id);
    }

    notifyListeners();
  }

  /// Save groups to local storage
  Future<void> saveGroupsToStorage() async {
    await StorageService.saveGroups(groupList);
  }
}
