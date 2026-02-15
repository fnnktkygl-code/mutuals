import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/family_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/member_manager.dart';
import '../theme/app_theme.dart';

/// Central app state — thin orchestrator.
///
/// Member CRUD is in [MemberManager] mixin.
/// Groups (Families) are managed directly here.
class AppState extends ChangeNotifier with MemberManager {
  // ---- Data owned by AppState, bridged to mixins via overrides ----

  List<Member> _members = [];
  Member? _currentUserProfile; // Cached "Moi" for consistency across groups
  
  // Multi-Group Architecture
  List<Family> _myGroups = [];
  String? _currentGroupId;

  @override
  List<Member> get memberList => _members;
  @override
  set memberList(List<Member> value) => _members = value;
  
  @override
  Member? get currentUserProfile => _currentUserProfile;
  @override
  set currentUserProfile(Member? value) => _currentUserProfile = value;

  @override
  bool get notificationsOn => _notificationsEnabled;

  // ---- Theme & Settings ----

  AppThemeMode _themeMode = AppThemeMode.light;
  AccentColor _accentColor = AccentColor.purple;
  bool _notificationsEnabled = false;
  ThemeData? _cachedTheme;

  // ---- Sync ----

  final AuthService _authService = AuthService();
  late final SyncService _syncService = SyncService(_authService);
  
  final bool _isSyncing = false;
  StreamSubscription? _membersSubscription;
  final List<StreamSubscription> _allMembersSubscriptions = [];
  final Map<String, List<Member>> _cachedMembersByGroup = {};
  StreamSubscription? _groupsSubscription; // Listens to list of families

  // ---- Getters ----

  AppThemeMode get themeMode => _themeMode;
  AccentColor get accentColor => _accentColor;
  bool get notificationsEnabled => _notificationsEnabled;

  @override
  AuthService get authService => _authService;
  @override
  SyncService get syncService => _syncService;
  
  @override
  bool get hasFamily => _currentGroupId != null;
  
  bool get isSyncing => _isSyncing;

  // Group Getters
  @override
  List<Family> get myGroups => _myGroups;
  List<Family> get visibleGroups => _myGroups.where((g) => !g.isPersonal).toList();
  Family? get personalGroup => _myGroups.where((g) => g.isPersonal).firstOrNull;
  
  @override
  String? get currentGroupId => _currentGroupId;
  Family? get currentGroup => _myGroups.where((g) => g.id == _currentGroupId).firstOrNull;
  String? get inviteCode => currentGroup?.inviteCode;
  
  // Create Personal Group logic
  Future<Family> createPersonalGroupIfNeeded() async {
    if (personalGroup != null) return personalGroup!;
    
    final user = _authService.currentUser;
    if (user == null) throw Exception("User not logged in");
    
    // Create hidden group
    final newGroup = Family(
        id: const Uuid().v4(), 
        name: "Mes Contacts", // Internal name, acceptable
        inviteCode: _generateInviteCode(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
        memberUids: [user.uid],
        isPersonal: true,
      );
      
     _myGroups = [..._myGroups, newGroup];
     notifyListeners();
     
     // Persist
     await FirebaseFirestore.instance
          .collection('families')
          .doc(newGroup.id)
          .set(newGroup.toJson());
          
     return newGroup;
  }

  @override
  List<String> getGroupIdsForMember(String memberId) {
    // Only used when currentGroupId == 'all', so cache should be populated.
    // If not 'all', return currentGroupId if available.
    if (_currentGroupId != 'all' && _currentGroupId != null) {
       return [_currentGroupId!];
    }
    
    final groupIds = <String>[];
    _cachedMembersByGroup.forEach((gid, members) {
       // Only include visible groups in the "chips" or logic?
       // The user requested: "if he joins will only appears in the 'tou' filter list"
       // So we should NOT return personal group IDs here if we want to hide them from "Tags"?
       // Actually, we probably want to filter out personal groups from "Shared" indicators.
       
       // Find group
       final group = _myGroups.where((g) => g.id == gid).firstOrNull;
       if (group != null && !group.isPersonal) {
          if (members.any((m) => m.id == memberId)) {
             groupIds.add(gid);
          }
       }
    });
    return groupIds;
  }

  /// Get current theme data (cached)
  ThemeData get currentTheme {
    _cachedTheme ??= AppTheme.generateTheme(_themeMode, _accentColor);
    return _cachedTheme!;
  }

  // ========== INITIALIZATION ==========

  Future<void> initialize() async {
    _themeMode = await ThemeService.loadThemeMode();
    _accentColor = await ThemeService.loadAccentColor();
    _notificationsEnabled = await StorageService.loadNotificationsEnabled();
    _members = await StorageService.loadMembers();
    _currentUserProfile = await StorageService.loadUserProfile();
    
    // Load Groups
    _myGroups = await StorageService.loadMyFamilies();
    _currentGroupId = await StorageService.loadActiveFamilyId();
    
    // Validate current group
    // Validate current group
    final current = _myGroups.where((g) => g.id == _currentGroupId).firstOrNull;
    // Switch if invalid group, or if it is a Personal group (which should be hidden)
    // We allow 'all' to persist.
    if (_currentGroupId != 'all' && (current == null || current.isPersonal)) {
        final visible = _myGroups.where((g) => !g.isPersonal).toList();
        if (visible.isNotEmpty) {
           _currentGroupId = visible.first.id;
        } else if (_myGroups.isNotEmpty) {
           _currentGroupId = 'all'; // Default to All if only personal exist
        } else {
           _currentGroupId = null;
        }
        await StorageService.saveActiveFamilyId(_currentGroupId);
    }

    await _authService.signInAnonymously();

    // Start Sync
    _startListeningToGroups();
    if (_currentGroupId != null) {
       _startListeningToMembers(_currentGroupId!);
    }

    if (_notificationsEnabled) {
      for (var member in _members) {
        if (member.birthday != null) {
          await NotificationService().scheduleBirthdayNotification(
            id: member.id,
            name: member.name,
            birthday: member.birthday!,
          );
        }
      }
    }

    notifyListeners();
  }

  // ========== GROUP MANAGEMENT ==========

  Future<void> createGroup(String name, {String? emoji, String? background}) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // 1. Create Group Object locally
      final newGroup = Family(
        id: const Uuid().v4(), 
        name: name,
        inviteCode: _generateInviteCode(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
        memberUids: [user.uid],
        emoji: emoji,
        background: background,
      );

      // 2. Optimistic Update (Local State)
      _myGroups = [..._myGroups, newGroup];
      await selectGroup(newGroup.id);
      notifyListeners();

      // 3. Persist group to Firestore
      await FirebaseFirestore.instance
          .collection('families')
          .doc(newGroup.id)
          .set(newGroup.toJson());

      // 4. Sync "Moi" profile to the new group's members collection
      final myProfile = _currentUserProfile ?? Member(
        id: user.uid,
        name: "Moi",
        gradient: 'from-purple-400 to-purple-600',
        isOwner: true,
      );
      // Ensure canonical Firebase UID
      final profileToSync = myProfile.id == user.uid
          ? myProfile
          : myProfile.copyWith(id: user.uid);
      await _syncService.syncMember(newGroup.id, profileToSync);

    } catch (e) {
      debugPrint('Error creating espace: $e');
      rethrow;
    }
  }

  Future<void> joinGroup(String inviteCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Find espace by code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('families')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Code d'invitation invalide");
      }

      final groupDoc = querySnapshot.docs.first;
      final group = Family.fromMap(groupDoc.data());

      // 2. Check if already member
      if (group.memberUids.contains(user.uid)) {
        // Already member, just switch to it
        if (!_myGroups.any((g) => g.id == group.id)) {
           _myGroups = [..._myGroups, group];
        }
        await selectGroup(group.id);
        return;
      }

      // 3. Add user to espace
      await FirebaseFirestore.instance
          .collection('families')
          .doc(group.id)
          .update({
        'memberUids': FieldValue.arrayUnion([user.uid])
      });

      // 4. Update local state
      // (The stream listener in SyncService should pick this up, but we can be optimistic)
      // For now, let's wait for the stream or just fetch it.
      // We'll manually add it to _myGroups to be responsive
      final updatedGroup = group.copyWith(
        memberUids: [...group.memberUids, user.uid]
      );
       _myGroups = [..._myGroups, updatedGroup];
       await selectGroup(group.id);
       
       // Also sync my profile to this new espace so I appear there
       // We need to find "my" member profile
       try {
         final myProfile = _members.firstWhere(
           (m) => m.id == user.uid, 
           orElse: () => Member(
             id: user.uid, 
             name: "Moi", 
             gradient: 'from-purple-400 to-purple-600',
             isOwner: true,
           )
         );
         await _syncService.syncMember(group.id, myProfile);
       } catch (e) {
         debugPrint("Error syncing profile to new espace: $e");
       }

    } catch (e) {
      debugPrint('Error joining espace: $e');
      rethrow;
    }
  }

  Future<void> selectGroup(String groupId) async {
    if (_currentGroupId == groupId) return;
    if (!_myGroups.any((g) => g.id == groupId)) return;
    
    await _setCurrentGroupInternal(groupId);
  }

  Future<void> selectAllGroups() async {
    if (_currentGroupId == 'all') return;
    await _setCurrentGroupInternal('all');
  }
  
  bool get isAllGroupsSelected => _currentGroupId == 'all';
  
  Future<void> _setCurrentGroupInternal(String? groupId) async {
      _currentGroupId = groupId;
      await StorageService.saveActiveFamilyId(groupId);
      
      _startListeningToMembers();
      notifyListeners();
  }

  Future<void> renameGroup(String groupId, String newName) async {
    final groupIndex = _myGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;
    
    // Optimistic update
    final oldGroup = _myGroups[groupIndex];
    final newGroup = oldGroup.copyWith(name: newName);
    _myGroups[groupIndex] = newGroup;
    
    await StorageService.saveMyFamilies(_myGroups);
    notifyListeners();
    
    try {
      await FirebaseFirestore.instance.collection('families').doc(groupId).update({
        'name': newName
      });
    } catch (e) {
      // Revert on failure
      _myGroups[groupIndex] = oldGroup;
      await StorageService.saveMyFamilies(_myGroups);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final isCurrent = _currentGroupId == groupId;
    
    // If leaving current, stop listening first
    if (isCurrent) {
      _membersSubscription?.cancel();
      _membersSubscription = null;
    }
    
    await _syncService.leaveGroup(groupId);
    
    _myGroups = _myGroups.where((g) => g.id != groupId).toList();
    await StorageService.saveMyFamilies(_myGroups);
    
    if (isCurrent) {
        if (_myGroups.isNotEmpty) {
          await _setCurrentGroupInternal(_myGroups.first.id);
        } else {
          _currentGroupId = null;
          await StorageService.saveActiveFamilyId(null);
          _members = [];
          await StorageService.saveMembers([]);
          notifyListeners();
        }
    } else {
       notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    final isCurrent = _currentGroupId == groupId;
    
    // Find family safely
    final family = _myGroups.where((g) => g.id == groupId).firstOrNull;
    if (family == null) return;
    
    // Check ownership
    if (family.createdBy != _authService.currentUser?.uid) {
       throw Exception("Vous n'êtes pas le créateur de cet espace.");
    }

    try {
      if (isCurrent) {
         _membersSubscription?.cancel();
         _membersSubscription = null;
      }

      await _syncService.deleteGroup(groupId);
      
      // Local clean up
      _myGroups = _myGroups.where((g) => g.id != groupId).toList();
      await StorageService.saveMyFamilies(_myGroups);

      if (isCurrent) {
          if (_myGroups.isNotEmpty) {
            // Prefer a visible group if possible
            final visible = _myGroups.where((g) => !g.isPersonal).firstOrNull;
            if (visible != null) {
               await _setCurrentGroupInternal(visible.id);
            } else {
               await _setCurrentGroupInternal(_myGroups.first.id);
            }
          } else {
            _currentGroupId = null;
            await StorageService.saveActiveFamilyId(null);
            _members = [];
            await StorageService.saveMembers([]);
            notifyListeners();
          }
      } else {
         notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting group: $e");
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    try {
      // 1. Iterate all groups to Clean up Firestore
      final groups = List<Family>.from(_myGroups);
      
      for (final group in groups) {
          if (group.createdBy == user.uid) {
             // Delete owned group
             try {
                // Determine if it's a personal group or shared
                // Regardless, delete it.
                await _syncService.deleteGroup(group.id);
             } catch (e) {
                debugPrint("Error deleting group ${group.id}: $e");
             }
          } else {
             // Leave shared group
             try {
                await _syncService.leaveGroup(group.id);
                // Also try to delete my member document from that group to be clean
                // families/{groupId}/members/{uid}
                try {
                   await FirebaseFirestore.instance
                       .collection('families')
                       .doc(group.id)
                       .collection('members')
                       .doc(user.uid)
                       .delete();
                } catch (_) {}
             } catch (e) {
                debugPrint("Error leaving group ${group.id}: $e");
             }
          }
      }
      
      // 2. Clear local data
      await resetApp();
      
      // 3. Sign out (and ideally delete auth user if supported)
      try {
        await user.delete();
      } catch (e) {
        debugPrint("Error deleting auth user: $e");
        await _authService.signOut();
      }

    } catch (e) {
        debugPrint("Error deleting account: $e");
        rethrow;
    }
  }

  Future<void> refreshData() async {
    // Mostly handled by streams, but can force check
    notifyListeners();
  }

  // ========== LISTENERS ==========

  void _startListeningToGroups() {
    _groupsSubscription?.cancel();
    _groupsSubscription = _syncService.listenToUserGroups().listen((remoteGroups) {
        // Always update, even if empty (e.g. all groups deleted)
        _myGroups = remoteGroups;
        StorageService.saveMyFamilies(_myGroups);
        
        // If current group was deleted remotely
        if (_currentGroupId != null && _currentGroupId != 'all' && !_myGroups.any((g) => g.id == _currentGroupId)) {
            if (_myGroups.isNotEmpty) {
                _setCurrentGroupInternal(_myGroups.first.id);
            } else {
                _currentGroupId = null;
                StorageService.saveActiveFamilyId(null);
                _members = _ensureCurrentUserInList([]); // Keep Moi
                StorageService.saveMembers(_members);
            }
        }
        notifyListeners();
    });
  }

  Future<void> _startListeningToMembers([String? groupId]) async {
    // Cancel existing
    await _membersSubscription?.cancel();
    _membersSubscription = null;
    
    for (final sub in _allMembersSubscriptions) {
      await sub.cancel();
    }
    _allMembersSubscriptions.clear();
    _cachedMembersByGroup.clear();

    final targetGroupId = groupId ?? _currentGroupId;

    if (targetGroupId == 'all') {
       if (_myGroups.isEmpty) {
          _members = _ensureCurrentUserInList([]);
          notifyListeners();
          return;
       }
       
       for (final group in _myGroups) {
          final sub = _syncService.listenToMembers(group.id).listen((members) {
             _cachedMembersByGroup[group.id] = members;
             _mergeAndSetAllMembers();
          });
          _allMembersSubscriptions.add(sub);
       }
    } else if (targetGroupId != null) {
       _membersSubscription = _syncService.listenToMembers(targetGroupId).listen(
        (remoteMembersList) {
            _processSingleGroupMembers(remoteMembersList);
        },
        onError: (e) => debugPrint('Members stream error: $e'),
      );
    } else {
      _members = _ensureCurrentUserInList([]);
      notifyListeners();
    }
  }

  void _mergeAndSetAllMembers() {
    final allMembers = _cachedMembersByGroup.values.expand((x) => x).toList();
    final currentUserId = _authService.currentUser?.uid;
    final profileId = _currentUserProfile?.id;

    final uniqueMembers = <String, Member>{};
    for (final m in allMembers) {
       // Filter restricted profiles
       if (currentUserId != null && !m.canView(currentUserId)) continue;
       
       // Skip current user entries here — _ensureCurrentUserInList handles "Moi"
       if (m.id == currentUserId) continue;
       if (profileId != null && m.id == profileId) continue;
       // Force isOwner to false for all remote members.
       // Ownership is determined by:
       // 1. currentUser matching the ID (handled below in _ensureCurrentUserInList)
       // 2. ownerId matching currentUser (Restricted Profiles) - handled by MemberDetailScreen check
       var processedMember = m.copyWith(isOwner: false);

       if (!uniqueMembers.containsKey(processedMember.id)) {
         uniqueMembers[processedMember.id] = processedMember;
       }
    }
    
    var processed = uniqueMembers.values.toList();
    _members = _ensureCurrentUserInList(processed);
    notifyListeners();
  }

  void _processSingleGroupMembers(List<Member> remoteMembersList) {
      final currentUserId = _authService.currentUser?.uid;
      List<Member> processedMembers = [];
      
      if (remoteMembersList.isNotEmpty) {
         // Deduplicate by ID immediately
         final uniqueMap = <String, Member>{};
         for (final m in remoteMembersList) {
            uniqueMap[m.id] = m;
         }
                  final filtered = uniqueMap.values.where((m) {
             if (currentUserId == null) return m.ownerId == null;
             return m.canView(currentUserId);
          }).map((m) => m.copyWith(isOwner: false)).toList();
         processedMembers = filtered.toList();
      }
      
      _members = _ensureCurrentUserInList(processedMembers);
      StorageService.saveMembers(_members);
      notifyListeners();
  }

  List<Member> _ensureCurrentUserInList(List<Member> list) {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return list;

    // Determine the canonical profile for "Moi".
    // Use the locally cached profile (most up-to-date), ensuring its ID
    // is the Firebase UID (fixes legacy profiles created with uuid.v4()).
    Member canonicalProfile;
    if (_currentUserProfile != null) {
        // Force the ID to be the Firebase UID, even if it was a random UUID
        canonicalProfile = _currentUserProfile!.id == currentUserId
            ? _currentUserProfile!
            : _currentUserProfile!.copyWith(id: currentUserId);
    } else {
        canonicalProfile = Member(
          id: currentUserId,
          name: "Profil",
          gradient: 'from-purple-400 to-purple-600',
          isOwner: true, 
        );
    }

    // Also track the old profile ID if it differs (legacy random UUID)
    final oldProfileId = _currentUserProfile?.id;
    
    // Strip ALL entries that represent the current user:
    //   - by Firebase UID
    //   - by the cached profile's (possibly different) ID
    //   - by isOwner flag from the same user
    final filtered = list.where((m) {
        if (m.id == currentUserId) return false;
        if (oldProfileId != null && m.id == oldProfileId) return false;
        return true;
    }).toList();

    // Deduplicate remaining by ID
    final uniqueMap = {for (var m in filtered) m.id: m};

    // Insert exactly ONE canonical "Moi" entry
    uniqueMap[currentUserId] = canonicalProfile;
    
    final result = uniqueMap.values.toList();
    
    // Sort: Moi first, then alphabetical
    result.sort((a, b) {
       if (a.id == currentUserId) return -1;
       if (b.id == currentUserId) return 1;
       return a.name.compareTo(b.name);
    });

    return result;
  }

  void _stopListening() {
    _membersSubscription?.cancel();
    _membersSubscription = null;
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  // ========== SETTINGS ==========

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await StorageService.saveNotificationsEnabled(value);

    if (value) {
      await NotificationService().requestPermissions();
      for (var member in _members) {
        if (member.birthday != null) {
          await NotificationService().scheduleBirthdayNotification(
            id: member.id,
            name: member.name,
            birthday: member.birthday!,
          );
        }
      }
    } else {
      await NotificationService().cancelAll();
    }
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    _cachedTheme = null;
    await ThemeService.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setAccentColor(AccentColor color) async {
    _accentColor = color;
    _cachedTheme = null;
    await ThemeService.saveAccentColor(color);
    notifyListeners();
  }

  // ========== RESET ==========

  Future<void> resetApp() async {
    _stopListening();
    await StorageService.clearAllData();
    _members = [];
    _myGroups = [];
    _currentGroupId = null;
    _themeMode = AppThemeMode.light;
    _accentColor = AccentColor.purple;
    notifyListeners();
  }
  // ========== DATA MANAGEMENT ==========

  String exportData() {
    final data = {
      'members': _members.map((m) => m.toJson()).toList(),
      'groups': _myGroups.map((g) => g.toJson()).toList(),
      'themeMode': _themeMode.index,
      'accentColor': _accentColor.index,
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      
      if (data['members'] != null) {
        _members = (data['members'] as List).map((m) => Member.fromJson(m)).toList();
        await StorageService.saveMembers(_members);
      }
      
      if (data['groups'] != null) {
        // We need to be careful with IDs
        final groups = (data['groups'] as List).map((g) => Family.fromJson(g['id'], g)).toList();
        _myGroups = groups;
        await StorageService.saveMyFamilies(_myGroups);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[(DateTime.now().microsecondsSinceEpoch * (index + 1)) % chars.length]).join();
  }
}
