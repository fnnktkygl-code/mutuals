import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/member_group.dart';
import '../models/family_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/member_manager.dart';
import '../services/group_manager.dart';
import '../theme/app_theme.dart';

/// Central app state — thin orchestrator.
///
/// Member CRUD is in [MemberManager] mixin.
/// Group CRUD is in [GroupManager] mixin.
class AppState extends ChangeNotifier with MemberManager, GroupManager {
  // ---- Data owned by AppState, bridged to mixins via overrides ----

  List<Member> _members = [];
  List<MemberGroup> _groups = [];
  // Map<MemberID, List<GroupID>>
  Map<String, List<String>> _privateGroupAssignments = {};

  @override
  List<Member> get memberList => _members;
  @override
  set memberList(List<Member> value) => _members = value;

  @override
  List<MemberGroup> get groupList => _groups;
  @override
  set groupList(List<MemberGroup> value) => _groups = value;

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
  Family? _family;
  bool _isSyncing = false;
  StreamSubscription? _membersSubscription;
  StreamSubscription? _groupsSubscription;

  // ---- Getters ----

  AppThemeMode get themeMode => _themeMode;
  AccentColor get accentColor => _accentColor;
  bool get notificationsEnabled => _notificationsEnabled;

  @override
  AuthService get authService => _authService;
  @override
  SyncService get syncService => _syncService;
  Family? get family => _family;
  @override
  bool get hasFamily => _family != null;
  bool get isSyncing => _isSyncing;
  String? get inviteCode => _family?.inviteCode;

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
    _groups = await StorageService.loadGroups();
    
    // Load private group assignments (or migrate from legacy member.groupIds if needed)
    _privateGroupAssignments = await StorageService.loadPrivateGroupAssignments();
    
    // Migration: If assignments empty but members have groupIds, fill the map
    if (_privateGroupAssignments.isEmpty && _members.isNotEmpty) {
      for (var m in _members) {
        if (m.groupIds.isNotEmpty) {
          _privateGroupAssignments[m.id] = List.from(m.groupIds);
        }
      }
      await StorageService.savePrivateGroupAssignments(_privateGroupAssignments);
    }

    initializeDefaultGroups();
    if (_groups.isNotEmpty) {
      await saveGroupsToStorage();
    }
    
    // No sequential ID calculation needed for UUIDs

    await _authService.signInAnonymously();

    final storedFamilyId = await StorageService.loadFamilyId();
    if (storedFamilyId != null) {
      _syncService.setFamilyId(storedFamilyId);
      _family = await _syncService.getFamily();
      if (_family != null) {
        _startListening();
      } else {
        await StorageService.saveFamilyId(null);
      }
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

  // ========== PRIVATE GROUP ASSIGNMENTS ==========

  List<String> getMemberGroupIds(String memberId) {
    if (_privateGroupAssignments.containsKey(memberId)) {
      return _privateGroupAssignments[memberId]!;
    }
    // Fallback: check member object for legacy/owner data
    final member = getMember(memberId);
    return member?.groupIds ?? [];
  }

  Future<void> updateMemberGroups(String memberId, List<String> groupIds) async {
    _privateGroupAssignments[memberId] = groupIds;
    await StorageService.savePrivateGroupAssignments(_privateGroupAssignments);
    notifyListeners();
  }

  // ========== FAMILY SYNC ==========

  Future<Family?> createFamily(String name) async {
    _isSyncing = true;
    notifyListeners();

    try {
      _family = await _syncService.createFamily(name);
      if (_family != null) {
        await StorageService.saveFamilyId(_family!.id);
        await _syncService.uploadAllMembers(_members);
        await _syncService.uploadAllGroups(_groups);
        _startListening();
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
    return _family;
  }

  Future<Family?> joinFamily(String inviteCode) async {
    _isSyncing = true;
    notifyListeners();

    try {
      _family = await _syncService.joinFamily(inviteCode);
      if (_family != null) {
        await StorageService.saveFamilyId(_family!.id);
        // Important: When joining, upload existing local members (e.g. "Moi")
        // and groups to the family collection so others can see them.
        await _syncService.uploadAllMembers(_members);
        if (_groups.isNotEmpty) {
           await _syncService.uploadAllGroups(_groups);
        }
        _startListening();
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
    return _family;
  }

  Future<void> leaveFamily() async {
    _stopListening();
    await _syncService.leaveFamily();
    await StorageService.saveFamilyId(null);
    _family = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isSyncing = true;
    notifyListeners();
    try {
      if (_family != null) {
        // Reload family info
        final freshFamily = await _syncService.getFamily();
        if (freshFamily != null) {
          _family = freshFamily;
          await StorageService.saveFamilyId(_family!.id);
        }
        // Restart listeners to ensure fresh streams
        _startListening();
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _startListening() {
    _stopListening();

    _membersSubscription = _syncService.listenToMembers().listen(
      (remoteMembersList) {
        if (remoteMembersList.isNotEmpty) {
          final currentUserId = _authService.currentUser?.uid;

          // FILTER: Only show Shared members (ownerId == null) OR Private members owned by ME.
          final filteredList = remoteMembersList.where((m) {
             return m.ownerId == null || (currentUserId != null && m.ownerId == currentUserId);
          }).toList();

          // Identify the current local owner ID to preserve 'isOwner' status
          final currentOwner = _members.where((m) => m.isOwner).firstOrNull;
          final ownerId = currentOwner?.id;

          _members = filteredList.map((remoteMember) {
             if (ownerId != null) {
               if (remoteMember.id == ownerId) {
                 return remoteMember.copyWith(isOwner: true);
               } else {
                 return remoteMember.copyWith(isOwner: false);
               }
             }
             return remoteMember.copyWith(isOwner: remoteMember.id == ownerId);
          }).toList();

          StorageService.saveMembers(_members);
          notifyListeners();
        }
      },
      onError: (e) => debugPrint('Members stream error: $e'),
    );

    _groupsSubscription = _syncService.listenToGroups().listen(
      (remoteGroupsList) {
        if (remoteGroupsList.isNotEmpty) {
          final currentUserId = _authService.currentUser?.uid;

          // FILTER: Only show Shared groups (ownerId == null) OR Private groups owned by ME.
          _groups = remoteGroupsList.where((g) {
             return g.ownerId == null || (currentUserId != null && g.ownerId == currentUserId);
          }).toList();

          StorageService.saveGroups(_groups);
          notifyListeners();
        }
      },
      onError: (e) => debugPrint('Groups stream error: $e'),
    );
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

  // ========== DATA EXPORT / IMPORT ==========

  String exportData() {
    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'members': _members.map((m) => m.toJson()).toList(),
      'groups': _groups.map((g) => g.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Basic validation
      if (!data.containsKey('members') || !data.containsKey('groups')) {
        throw const FormatException('Format de données invalide');
      }

      final List<dynamic> membersJson = data['members'];
      final List<dynamic> groupsJson = data['groups'];

      final newMembers = membersJson.map((m) => Member.fromJson(m)).toList();
      final newGroups = groupsJson.map((g) => MemberGroup.fromJson(g)).toList();

      // Update state
      _members = newMembers;
      _groups = newGroups;
      
      // Save to persistence
      await StorageService.saveMembers(_members);
      await StorageService.saveGroups(_groups);
      
      // If synced, ensure cloud is updated
      if (_family != null) {
         await _syncService.uploadAllMembers(_members);
         await _syncService.uploadAllGroups(_groups);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow; 
    }
  }

  // ========== RESET ==========

  Future<void> resetApp() async {
    _stopListening();
    await StorageService.clearAllData();
    _members = [];
    _groups = [];
    _family = null;
    _themeMode = AppThemeMode.light;
    _accentColor = AccentColor.purple;
    notifyListeners();
  }
}
