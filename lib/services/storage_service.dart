import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/member_group.dart';

class StorageService {
  static const String _membersKey = 'famille_io_members';
  static const String _groupsKey = 'famille_io_groups';
  static const String _darkModeKey = 'famille_io_dark_mode';
  static const String _hasOnboardedKey = 'famille_io_has_onboarded';
  static const String _notificationsEnabledKey = 'famille_io_notifications_enabled';

  /// Save members list to storage
  static Future<void> saveMembers(List<Member> members) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = members.map((m) => m.toJson()).toList();
    await prefs.setString(_membersKey, jsonEncode(jsonList));
  }

  /// Load members list from storage
  static Future<List<Member>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_membersKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading members: $e');
      return [];
    }
  }

  /// Save dark mode preference
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  /// Load dark mode preference
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// Save onboarding state
  static Future<void> setHasOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasOnboardedKey, value);
  }

  /// Check if user has completed onboarding
  static Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasOnboardedKey) ?? false;
  }

  /// Clear all app data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Save notifications enabled state
  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Load notifications enabled state
  static Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Save groups list to storage
  static Future<void> saveGroups(List<MemberGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = groups.map((g) => g.toJson()).toList();
    await prefs.setString(_groupsKey, jsonEncode(jsonList));
  }

  /// Load groups list from storage
  static Future<List<MemberGroup>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_groupsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => MemberGroup.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading groups: $e');
      return [];
    }
  }
  
  // ========== PRIVATE ASSIGNMENTS ==========
  
  static const String _privateGroupAssignmentsKey = 'famille_io_private_group_assignments';

  static Future<void> savePrivateGroupAssignments(Map<String, List<String>> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert Map<String, List<String>> to Map<String, dynamic> for JSON encoding
    await prefs.setString(_privateGroupAssignmentsKey, jsonEncode(assignments));
  }

  static Future<Map<String, List<String>>> loadPrivateGroupAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_privateGroupAssignmentsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      // specific casting to ensure Map<String, List<String>>
      return jsonMap.map((key, value) {
         final list = (value as List).map((e) => e.toString()).toList();
         return MapEntry(key, list);
      });
    } catch (e) {
      debugPrint('Error loading private group assignments: $e');
      return {};
    }
  }

  // ========== FAMILY SYNC ==========

  static const String _familyIdKey = 'famille_io_family_id';

  /// Save the family ID locally (for reconnecting on restart)
  static Future<void> saveFamilyId(String? familyId) async {
    final prefs = await SharedPreferences.getInstance();
    if (familyId == null) {
      await prefs.remove(_familyIdKey);
    } else {
      await prefs.setString(_familyIdKey, familyId);
    }
  }

  /// Load the saved family ID
  static Future<String?> loadFamilyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_familyIdKey);
  }
  // ========== TUTORIALS ==========
  static const String _homeTutorialKey = 'famille_io_tutorial_home';
  static const String _timelineTutorialKey = 'famille_io_tutorial_timeline';
  static const String _memberTutorialKey = 'famille_io_tutorial_member';

  static Future<bool> hasShownHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeTutorialKey) ?? false;
  }

  static Future<void> setShownHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeTutorialKey, true);
  }

  static Future<bool> hasShownTimelineTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_timelineTutorialKey) ?? false;
  }

  static Future<void> setShownTimelineTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timelineTutorialKey, true);
  }

  static Future<bool> hasShownMemberTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_memberTutorialKey) ?? false;
  }

  static Future<void> setShownMemberTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_memberTutorialKey, true);
  }
  static Future<bool> hasShownFamilyTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('shown_family_tutorial') ?? false;
  }

  static Future<void> setShownFamilyTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shown_family_tutorial', true);
  }

  static Future<void> resetTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeTutorialKey);
    await prefs.remove(_timelineTutorialKey);
    await prefs.remove(_memberTutorialKey);
  }
}

