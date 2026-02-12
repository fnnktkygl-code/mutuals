import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/member_group.dart';
import '../models/family_model.dart';
import 'auth_service.dart';

/// Handles real-time synchronization with Firebase Firestore
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth;

  String? _familyId;

  /// Current family ID
  String? get familyId => _familyId;

  /// Whether we are connected to a family
  bool get hasFamily => _familyId != null;

  SyncService(this._auth);

  // ========== FAMILY MANAGEMENT ==========

  /// Create a new family and return the invite code
  Future<Family?> createFamily(String name) async {
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
      _familyId = familyRef.id;

      debugPrint('SyncService: Created family "$name" with code $inviteCode');
      return family;
    } catch (e) {
      debugPrint('SyncService: Failed to create family: $e');
      return null;
    }
  }

  /// Join an existing family by invite code
  Future<Family?> joinFamily(String inviteCode) async {
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
        debugPrint('SyncService: No family found with code $code');
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

      _familyId = doc.id;
      debugPrint('SyncService: Joined family "${family.name}"');
      return family.copyWith(
        memberUids: [...family.memberUids, if (!family.memberUids.contains(uid)) uid],
      );
    } catch (e) {
      debugPrint('SyncService: Failed to join family: $e');
      return null;
    }
  }

  /// Get current family info
  Future<Family?> getFamily() async {
    if (_familyId == null) return null;

    try {
      final doc = await _firestore.collection('families').doc(_familyId).get();
      if (!doc.exists) return null;
      return Family.fromJson(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('SyncService: Failed to get family: $e');
      return null;
    }
  }

  /// Load family for a user (find if they belong to one)
  Future<Family?> loadUserFamily() async {
    final uid = _auth.uid;
    if (uid == null) return null;

    try {
      final query = await _firestore
          .collection('families')
          .where('memberUids', arrayContains: uid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      _familyId = doc.id;
      return Family.fromJson(doc.id, doc.data());
    } catch (e) {
      debugPrint('SyncService: Failed to load user family: $e');
      return null;
    }
  }

  /// Leave current family
  Future<void> leaveFamily() async {
    final uid = _auth.uid;
    if (uid == null || _familyId == null) return;

    try {
      await _firestore.collection('families').doc(_familyId).update({
        'memberUids': FieldValue.arrayRemove([uid]),
      });
      _familyId = null;
      debugPrint('SyncService: Left family');
    } catch (e) {
      debugPrint('SyncService: Failed to leave family: $e');
    }
  }

  // ========== MEMBER SYNC ==========

  /// Upload a member to Firestore
  Future<void> syncMember(Member member) async {
    if (_familyId == null) return;

    try {
      await _membersCollection
          .doc(member.id)
          .set(member.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('SyncService: Failed to sync member ${member.name}: $e');
    }
  }

  /// Delete a member from Firestore
  Future<void> deleteMemberRemote(String memberId) async {
    if (_familyId == null) return;

    try {
      await _membersCollection.doc(memberId).delete();
    } catch (e) {
      debugPrint('SyncService: Failed to delete member $memberId: $e');
    }
  }

  /// Listen to all members (real-time stream)
  Stream<List<Member>> listenToMembers() {
    if (_familyId == null) {
      return const Stream.empty();
    }

    return _membersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Member.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Upload all members at once (initial migration)
  Future<void> uploadAllMembers(List<Member> members) async {
    if (_familyId == null) return;

    try {
      final batch = _firestore.batch();
      for (final member in members) {
        final ref = _membersCollection.doc(member.id);
        batch.set(ref, member.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('SyncService: Uploaded ${members.length} members');
    } catch (e) {
      debugPrint('SyncService: Failed to upload members: $e');
    }
  }

  // ========== GROUP SYNC ==========

  /// Upload a group to Firestore
  Future<void> syncGroup(MemberGroup group) async {
    if (_familyId == null) return;

    try {
      await _groupsCollection.doc(group.id).set(group.toJson());
    } catch (e) {
      debugPrint('SyncService: Failed to sync group ${group.name}: $e');
    }
  }

  /// Delete a group from Firestore
  Future<void> deleteGroupRemote(String groupId) async {
    if (_familyId == null) return;

    try {
      await _groupsCollection.doc(groupId).delete();
    } catch (e) {
      debugPrint('SyncService: Failed to delete group $groupId: $e');
    }
  }

  /// Listen to all groups (real-time stream)
  Stream<List<MemberGroup>> listenToGroups() {
    if (_familyId == null) {
      return const Stream.empty();
    }

    return _groupsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MemberGroup.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Upload all groups at once (initial migration)
  Future<void> uploadAllGroups(List<MemberGroup> groups) async {
    if (_familyId == null) return;

    try {
      final batch = _firestore.batch();
      for (final group in groups) {
        final ref = _groupsCollection.doc(group.id);
        batch.set(ref, group.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('SyncService: Uploaded ${groups.length} groups');
    } catch (e) {
      debugPrint('SyncService: Failed to upload groups: $e');
    }
  }

  // ========== HELPERS ==========

  /// Reference to the members subcollection
  CollectionReference get _membersCollection =>
      _firestore.collection('families').doc(_familyId).collection('members');

  /// Reference to the groups subcollection
  CollectionReference get _groupsCollection =>
      _firestore.collection('families').doc(_familyId).collection('groups');

  /// Generate a random 6-character invite code (uppercase letters + digits)
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No 0/O/1/I confusion
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Set family ID (e.g., loaded from local storage)
  void setFamilyId(String? id) {
    _familyId = id;
  }
}
