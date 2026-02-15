import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/family_model.dart';
import 'auth_service.dart';

/// Handles real-time synchronization with Firebase Firestore
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth;

  SyncService(this._auth);

  // ========== GROUP (FAMILY) MANAGEMENT ==========

  /// Create a new group and return it
  Future<Family?> createGroup(String name) async {
    final uid = _auth.uid;
    if (uid == null) return null;

    try {
      final inviteCode = _generateInviteCode();

      final familyRef = _firestore.collection('families').doc();
      final family = Family(
        id: familyRef.id,
        name: name,
        inviteCode: inviteCode,
        createdBy: uid,
        createdAt: DateTime.now(),
        memberUids: [uid],
      );

      await familyRef.set(family.toJson());
      
      debugPrint('SyncService: Created group "$name" with code $inviteCode');
      return family;
    } catch (e) {
      debugPrint('SyncService: Failed to create group: $e');
      return null;
    }
  }

  /// Join an existing group by invite code
  Future<Family?> joinGroup(String inviteCode) async {
    final uid = _auth.uid;
    if (uid == null) return null;

    try {
      final code = inviteCode.toUpperCase().trim();
      final query = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('SyncService: No group found with code $code');
        return null;
      }

      final doc = query.docs.first;
      final family = Family.fromJson(doc.id, doc.data());

      // Add user to family if not already a member
      if (!family.memberUids.contains(uid)) {
        await doc.reference.update({
          'memberUids': FieldValue.arrayUnion([uid]),
        });
      }

      debugPrint('SyncService: Joined group "${family.name}"');
      return family.copyWith(
        memberUids: [...family.memberUids, if (!family.memberUids.contains(uid)) uid],
      );
    } catch (e) {
      debugPrint('SyncService: Failed to join group: $e');
      return null;
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String familyId) async {
    final uid = _auth.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('families').doc(familyId).update({
        'memberUids': FieldValue.arrayRemove([uid]),
      });
      debugPrint('SyncService: Left group $familyId');
    } catch (e) {
      debugPrint('SyncService: Failed to leave group: $e');
    }
  }

  /// Delete a group (Owner only)
  Future<void> deleteGroup(String familyId) async {
    final uid = _auth.uid;
    if (uid == null) return;

    try {
      // 1. Verify ownership (optional, mostly reinforced by Security Rules)
      // 2. Delete the doc
      await _firestore.collection('families').doc(familyId).delete();
      
      // Note: Subcollections (members) are NOT automatically deleted by client SDK.
      // Ideally this should be done via Cloud Functions or by iterating members.
      // For this MVP, we just delete the parent. The app handles missing parents gracefully.
      
      debugPrint('SyncService: Deleted group $familyId');
    } catch (e) {
      debugPrint('SyncService: Failed to delete group: $e');
      rethrow;
    }
  }
  
  /// Listen to ALL groups the user belongs to
  Stream<List<Family>> listenToUserGroups() {
    final uid = _auth.uid;
    if (uid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('families')
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Family.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // ========== MEMBER SYNC ==========

  /// Upload a member to Firestore (Specific Group)
  Future<void> syncMember(String groupId, Member member) async {
    try {
      await _firestore
          .collection('families')
          .doc(groupId)
          .collection('members')
          .doc(member.id)
          .set(member.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('SyncService: Failed to sync member ${member.name} to $groupId: $e');
    }
  }

  /// Delete a member from Firestore (Specific Group)
  Future<void> deleteMemberRemote(String groupId, String memberId) async {
    try {
      await _firestore
          .collection('families')
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .delete();
    } catch (e) {
      debugPrint('SyncService: Failed to delete member $memberId from $groupId: $e');
    }
  }

  /// Listen to members of a SPECIFIC group
  Stream<List<Member>> listenToMembers(String groupId) {
    return _firestore
        .collection('families')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Member.fromJson(doc.data());
      }).toList();
    });
  }

  /// Upload list of members to a group (Initial Sync/Join)
  Future<void> uploadMembersToGroup(String groupId, List<Member> members) async {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('families').doc(groupId).collection('members');
      
      for (final member in members) {
        final ref = collection.doc(member.id);
        batch.set(ref, member.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('SyncService: Uploaded ${members.length} members to $groupId');
    } catch (e) {
      debugPrint('SyncService: Failed to upload members: $e');
    }
  }

  // ========== HELPERS ==========

  /// Generate a random 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
