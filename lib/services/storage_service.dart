import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/family_model.dart';

class StorageService {
  static const String _membersKey = 'famille_io_members';
  static const String _darkModeKey = 'famille_io_dark_mode';
  static const String _hasOnboardedKey = 'famille_io_has_onboarded';
  static const String _notificationsEnabledKey = 'famille_io_notifications_enabled';
  
  static const String _familiesKey = 'famille_io_my_families';
  static const String _activeFamilyIdKey = 'famille_io_active_family_id';

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
  
  static const String _userProfileKey = 'famille_io_user_profile';

  /// Save User Profile (Moi cache)
  static Future<void> saveUserProfile(Member member) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(member.toJson()));
  }

  /// Load User Profile (Moi cache)
  static Future<Member?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    
    try {
      return Member.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  /// Save My Families (Groups)
  static Future<void> saveMyFamilies(List<Family> families) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = families.map((f) => f.toJson()).toList();
    await prefs.setString(_familiesKey, jsonEncode(jsonList));
  }

  /// Load My Families (Groups)
  static Future<List<Family>> loadMyFamilies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_familiesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      // Filter out any potential nulls or errors
      return jsonList.map((json) => Family.fromJson(json['id'] ?? '', json)).toList();
    } catch (e) {
      debugPrint('Error loading families: $e');
      return [];
    }
  }

  /// Save Active Family ID
  static Future<void> saveActiveFamilyId(String? familyId) async {
    final prefs = await SharedPreferences.getInstance();
    if (familyId == null) {
      await prefs.remove(_activeFamilyIdKey);
    } else {
      await prefs.setString(_activeFamilyIdKey, familyId);
    }
  }

  /// Load Active Family ID
  static Future<String?> loadActiveFamilyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeFamilyIdKey);
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

  static Future<void> resetTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeTutorialKey);
    await prefs.remove(_timelineTutorialKey);
    await prefs.remove(_memberTutorialKey);
  }
}
