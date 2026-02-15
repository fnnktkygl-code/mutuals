import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../models/member.dart';
import '../widgets/member_avatar.dart';
import '../widgets/filou_bubble.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../theme/filou_state.dart';
import '../models/family_model.dart';
import 'package:uuid/uuid.dart';
import '../models/fit_preference.dart';

import 'contact_import_screen.dart';
import 'member_detail_screen.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentGroup = appState.currentGroup;
    final members = appState.members;
    final currentUser = appState.authService.currentUser;
    final currentUserUid = currentUser?.uid;

    // Filter Logic
    final allFiltered = members.where((m) {
      return m.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Separate "Me" from "Others"
    Member? myProfile;
    List<Member> otherMembers = [];

    if (currentUserUid != null) {
      // 1. Priority: Use cached "Moi" profile (instant updates)
      if (appState.currentUserProfile != null) {
          myProfile = appState.currentUserProfile;
      } else {
      // 2. Fallback: Try to find in list or create default
          final me = allFiltered.where((m) => m.id == currentUserUid).firstOrNull;
          if (me != null) {
             myProfile = me;
          } else {
             myProfile = Member(
                id: currentUserUid,
                name: "Moi", 
                gradient: 'from-purple-400 to-purple-600',
                isOwner: true,
             );
          }
      }
      
      // Filter out "Me" from others list to avoid duplication
      // Explicitly exclude the ID of the profile we decided is "Me "
      if (myProfile != null) {
          otherMembers = allFiltered.where((m) => m.id != myProfile!.id).toList();
      } else {
          otherMembers = allFiltered.where((m) => m.id != currentUserUid).toList();
      }
    } else {
      otherMembers = allFiltered;
    }
    
    // Sort others alphabetically
    otherMembers.sort((a, b) => a.name.compareTo(b.name));

    final isAllGroups = appState.isAllGroupsSelected;

    return Scaffold(
      floatingActionButton: (isAllGroups || currentGroup == null) ? null : FloatingActionButton.extended(
        onPressed: () => _showAddMemberOptions(context, currentGroup),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Ajouter'),
      ),
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER
            Container(
              color: context.colors.surface,
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title (Matches TimelineScreen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                         Text(
                            'Vos ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: context.colors.onSurface,
                              letterSpacing: -1.0,
                            ),
                          ),
                          Text(
                            'Membres',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: context.colors.primary,
                              letterSpacing: -1.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                    // 2. Horizontal Group Selector
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: appState.visibleGroups.length + 2, // Tous + Groups + Add
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // 1. "Add" Button (Last)
                        if (index == appState.visibleGroups.length + 1) {
                          return GestureDetector(
                            onTap: () => _showAddSpaceSheet(context),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                   color: context.colors.outline.withValues(alpha: 0.2), 
                                   style: BorderStyle.solid
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.add_rounded, color: context.colors.primary, size: 24),
                            ),
                          );
                        }

                        // 2. "Tous" Button (First)
                        if (index == 0) {
                          final isSelected = appState.isAllGroupsSelected;
                          return GestureDetector(
                            onTap: () => appState.selectAllGroups(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? context.colors.primary 
                                    : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                   color: isSelected ? Colors.transparent : context.colors.outline.withValues(alpha: 0.1),
                                ),
                                boxShadow: isSelected 
                                    ? [BoxShadow(color: context.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Text(
                                'Tous',
                                style: TextStyle(
                                  color: isSelected ? context.colors.onPrimary : context.colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        // 3. Groups (Shifted by 1)
                        final group = appState.visibleGroups[index - 1];
                        final isSelected = currentGroup?.id == group.id;

                        return GestureDetector(
                          onTap: () => appState.selectGroup(group.id),
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            _showGroupOptionsSheet(context, group);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? context.colors.primary 
                                  : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                   color: isSelected ? Colors.transparent : context.colors.outline.withValues(alpha: 0.1),
                                ),
                              boxShadow: isSelected 
                                  ? [BoxShadow(color: context.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              group.name,
                              style: TextStyle(
                                color: isSelected ? context.colors.onPrimary : context.colors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 3. Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: context.colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(color: context.colors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un membre...',
                          hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
                          prefixIcon: Icon(Icons.search_rounded, color: context.colors.onSurfaceVariant),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // SCROLLABLE LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // "Moi" Section is ALWAYS visible now
                  if (myProfile != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
                      child: Text(
                        'MOI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _buildMemberRow(context, myProfile, isMe: true),
                    const SizedBox(height: 24),
                  ],

                  // "Others" Section
                  if (otherMembers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        'COMMUNAUTÉ (${otherMembers.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...otherMembers.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMemberRow(context, m, isMe: false),
                    )),
                  ],
                  
                  if (currentGroup == null && appState.myGroups.isEmpty && otherMembers.isEmpty) ...[
                      // True empty state (New User)
                      _buildEmptyState(context),
                  ] else if ((currentGroup != null || appState.isAllGroupsSelected) && otherMembers.isEmpty && myProfile != null) ...[
                     _buildInvitePrompt(context), // New prompt instead of "No Members Found"
                  ] else if (myProfile != null && otherMembers.isEmpty) ...[
                     // Just me, no group selected?
                     const SizedBox.shrink(),
                  ],
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSpaceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Filou greeting
            const Text('🐼', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              'Un nouvel espace ?',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crée ou rejoins un groupe de proches.',
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
            const SizedBox(height: 24),
            _buildSheetAction(
              context: context,
              icon: Icons.add_circle_outline,
              label: 'Créer un espace',
              subtitle: 'Invite tes proches avec un code',
              color: context.semantic.mascot,
              onTap: () {
                Navigator.pop(sheetContext);
                _showCreateSpaceSheet(context);
              },
            ),
            const SizedBox(height: 12),
            _buildSheetAction(
              context: context,
              icon: Icons.login_rounded,
              label: 'Rejoindre un espace',
              subtitle: 'Entre le code d\'un ami',
              color: context.colors.primary,
              onTap: () {
                Navigator.pop(sheetContext);
                _showJoinSpaceSheet(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: context.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: context.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitePrompt(BuildContext context) {
    return Center(
      child: FilouBubble(
        state: FilouState.phone,
        message: 'C\'est calme ici...\nInvite des proches pour commencer !',
        actionLabel: 'Inviter',
        imageSize: 220,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactImportScreen()));
        },
      ),
    );
  }

  /// Computes days until member's next birthday (null if no birthday).
  int? _daysUntilBirthday(Member member) {
    if (member.birthday == null) return null;
    final now = DateTime.now();
    var next = DateTime(now.year, member.birthday!.month, member.birthday!.day);
    if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
      next = DateTime(now.year + 1, member.birthday!.month, member.birthday!.day);
    }
    return next.difference(now).inDays;
  }

  Widget _buildMemberRow(BuildContext context, Member member, {required bool isMe}) {
    final now = DateTime.now();
    final currentMonthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final currentWish = member.wishHistory.where((w) => w.monthKey == currentMonthKey).firstOrNull;
    final daysUntil = _daysUntilBirthday(member);
    final hasBirthdaySoon = daysUntil != null && daysUntil <= 30;

    // Build subtitle line
    String subtitle;
    if (isMe) {
      subtitle = member.relationship.isNotEmpty && member.relationship != 'Moi'
          ? member.relationship
          : 'Mon profil';
    } else if (member.relationship.isNotEmpty && member.relationship != 'Membre') {
      subtitle = member.relationship;
    } else if (member.birthday != null) {
      subtitle = 'Anniversaire : ${member.birthday!.day}/${member.birthday!.month}';
    } else {
      subtitle = 'Membre';
    }

    // Accent color from avatar gradient or primary
    final accentColor = isMe
        ? context.colors.primary
        : (member.avatarBackgroundColor != null
            ? _parseHexColor(member.avatarBackgroundColor!)
            : context.colors.primary.withValues(alpha: 0.7));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemberDetailScreen(memberId: member.id)),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isMe
              ? accentColor.withValues(alpha: 0.06)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: isMe
                ? accentColor.withValues(alpha: 0.2)
                : context.colors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor.withValues(alpha: 0.8),
                      accentColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Row(
                    children: [
                      // Avatar
                      Hero(
                        tag: 'avatar_${member.id}',
                        child: MemberAvatar(member: member, size: 52, showBorder: false),
                      ),
                      const SizedBox(width: 14),
                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Name row + birthday badge
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    member.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '✨ Moi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                                if (hasBirthdaySoon && !isMe) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🎂 ${daysUntil}j',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            // Wish chip (if exists)
                            if (currentWish != null && currentWish.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: context.colors.primary.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, size: 13, color: context.colors.primary.withValues(alpha: 0.7)),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        currentWish.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Tags row
                            if (member.tags.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: member.tags.take(3).map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.onSurfaceVariant),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Completion gauge + Wizz
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circular completion gauge (Only for Me)
                          if (isMe)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MemberDetailScreen(memberId: member.id),
                                ));
                              },
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: member.completionPercentage,
                                      strokeWidth: 3,
                                      backgroundColor: context.colors.outlineVariant.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        member.completionPercentage >= 0.8
                                            ? const Color(0xFF22C55E)
                                            : member.completionPercentage >= 0.5
                                                ? const Color(0xFFF59E0B)
                                                : const Color(0xFFEF4444),
                                      ),
                                    ),
                                    Text(
                                      '${(member.completionPercentage * 100).round()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Wizz button (only for non-self members)
                          if (!isMe)
                            GestureDetector(
                              onTap: () => _showWizzSheet(context, member),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('💥', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.purple;
    }
  }

  void _showWizzSheet(BuildContext context, Member member) {
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);

    final wizzOptions = [
      {
        'emoji': '📝',
        'title': 'Complète ton profil !',
        'subtitle': 'Ajoute tes infos pour que tes proches sachent quoi t\'offrir',
        'color': const Color(0xFF8B5CF6),
        'notifTitle': '💥 Wizz de ${member.name} !',
        'notifBody': 'Hey ! Complète ton profil pour qu\'on puisse te faire plaisir 🎁',
      },
      {
        'emoji': '📏',
        'title': 'Mets à jour tes tailles',
        'subtitle': 'On veut pas se tromper de taille pour le prochain cadeau !',
        'color': const Color(0xFF3B82F6),
        'notifTitle': '📏 Rappel tailles !',
        'notifBody': '${member.name} aimerait que tu mettes à jour tes tailles. C\'est rapide ! ✨',
      },
      {
        'emoji': '🎂',
        'title': 'Partage ton anniversaire',
        'subtitle': 'Pour ne jamais rater ta date et te préparer une surprise',
        'color': const Color(0xFFEC4899),
        'notifTitle': '🎂 C\'est quand ton anniv ?',
        'notifBody': '${member.name} veut connaître ta date d\'anniversaire pour te préparer une surprise ! 🤫',
      },
      {
        'emoji': '📬',
        'title': 'Partage ton adresse',
        'subtitle': 'Pour recevoir des cadeaux directement chez toi !',
        'color': const Color(0xFF10B981),
        'notifTitle': '📬 Où t\'envoyer ton cadeau ?',
        'notifBody': '${member.name} aimerait avoir ton adresse pour te faire livrer une surprise ! 🎁',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('💥', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wizz ${member.name}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: context.colors.onSurface,
                          ),
                        ),
                        Text(
                          'Envoie un petit rappel sympa 😏',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Wizz options
            ...wizzOptions.map((opt) {
              final color = opt['color'] as Color;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      Navigator.pop(context);
                      // Send local notification
                      NotificationService().notificationsPlugin.show(
                        id: member.id.hashCode + (opt['emoji'] as String).hashCode,
                        title: opt['notifTitle'] as String,
                        body: opt['notifBody'] as String,
                        notificationDetails: const NotificationDetails(
                          iOS: DarwinNotificationDetails(),
                          android: AndroidNotificationDetails(
                            'wizz_channel',
                            'Wizz',
                            channelDescription: 'Notifications Wizz',
                            importance: Importance.high,
                            priority: Priority.high,
                          ),
                        ),
                      );
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '💥 Wizz envoyé à ${member.name} !',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: color,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              opt['emoji'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['title'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: color.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: FilouBubble(
        state: FilouState.confused,
        message: 'Filou cherche tes proches...\nInvite quelqu\'un pour commencer !',
        actionLabel: 'Inviter',
        imageSize: 220,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ContactImportScreen()),
          );
        },
      ),
    );
  }

  // Categorized emoji sets for group creation
  static const _emojiCategories = <String, List<String>>{
    '❤️ Famille': ['🏠', '👨‍👩‍👧‍👦', '👪', '👫', '👩‍👧', '👨‍👦', '🏡', '❤️', '💕', '🫶', '👶', '🧸'],
    '🏅 Sport': ['⚽', '🏀', '🎾', '🏈', '⛷️', '🎿', '🏊', '🚴', '🏃', '🧗', '🏋️', '⛳'],
    '🎉 Loisirs': ['🎮', '🎵', '🎬', '🎨', '📸', '🎲', '🎯', '🎭', '🎪', '🎤', '🎸', '🎻'],
    '✈️ Voyage': ['🏖️', '⛰️', '🏔️', '🌍', '✈️', '🚗', '⛺', '🏕️', '🗺️', '🌴', '🎒', '🚀'],
    '📚 Études': ['🎓', '📚', '✏️', '🔬', '💻', '🧪', '📖', '🏫', '📐', '🧮', '🎯', '💡'],
    '💼 Pro': ['💼', '🏢', '💰', '📊', '🤝', '📈', '⚙️', '🖥️', '📱', '🔧', '🏗️', '🌐'],
    '🐾 Animaux': ['🐼', '🐶', '🐱', '🐴', '🦊', '🐸', '🦋', '🐝', '🐳', '🦄', '🐧', '🐾'],
    '✨ Vibes': ['🌟', '🔥', '💎', '🌈', '☀️', '🌙', '⭐', '🎀', '🦩', '🍀', '🌸', '🫧'],
    '📲 Réseaux': ['📸', '🐦', '🎵', '💬', '📌', '🎮', '💼', '📺', '🎶', '🤖', '🍎', '💻', '🔗', '📧', '📡', '🛒'],
    '🌍 Drapeaux': [
      // Europe
      '🇫🇷', '🇩🇪', '🇮🇹', '🇪🇸', '🇬🇧', '🇵🇹', '🇳🇱', '🇧🇪', '🇨🇭', '🇦🇹', '🇮🇪', '🇸🇪',
      '🇳🇴', '🇩🇰', '🇫🇮', '🇵🇱', '🇨🇿', '🇷🇴', '🇭🇺', '🇬🇷', '🇭🇷', '🇸🇰', '🇧🇬', '🇷🇸',
      '🇺🇦', '🇱🇹', '🇱🇻', '🇪🇪', '🇸🇮', '🇲🇪', '🇲🇰', '🇦🇱', '🇧🇦', '🇲🇩', '🇱🇺', '🇲🇹',
      '🇮🇸', '🇨🇾', '🇬🇪', '🇦🇲', '🇦🇿', '🇧🇾', '🇽🇰',
      // Americas
      '🇺🇸', '🇨🇦', '🇲🇽', '🇧🇷', '🇦🇷', '🇨🇴', '🇨🇱', '🇵🇪', '🇻🇪', '🇪🇨', '🇺🇾', '🇵🇾',
      '🇧🇴', '🇨🇷', '🇵🇦', '🇨🇺', '🇩🇴', '🇬🇹', '🇭🇳', '🇸🇻', '🇳🇮', '🇭🇹', '🇯🇲', '🇹🇹',
      '🇧🇧', '🇧🇸', '🇬🇾', '🇸🇷', '🇧🇿', '🇵🇷',
      // Africa
      '🇲🇦', '🇹🇳', '🇩🇿', '🇪🇬', '🇱🇾', '🇳🇬', '🇬🇭', '🇰🇪', '🇪🇹', '🇹🇿', '🇿🇦', '🇸🇳',
      '🇨🇮', '🇨🇲', '🇨🇩', '🇦🇴', '🇲🇿', '🇲🇬', '🇿🇼', '🇺🇬', '🇷🇼', '🇲🇱', '🇧🇫', '🇳🇪',
      '🇹🇩', '🇬🇦', '🇧🇯', '🇹🇬', '🇸🇱', '🇱🇷', '🇬🇳', '🇲🇷', '🇪🇷', '🇩🇯', '🇸🇴', '🇸🇩',
      '🇸🇸', '🇳🇦', '🇧🇮', '🇲🇺', '🇸🇨', '🇰🇲', '🇨🇻', '🇬🇲', '🇬🇶', '🇸🇿', '🇱🇸', '🇧🇼',
      // Asia
      '🇯🇵', '🇨🇳', '🇰🇷', '🇮🇳', '🇮🇩', '🇹🇭', '🇻🇳', '🇵🇭', '🇲🇾', '🇸🇬', '🇲🇲', '🇰🇭',
      '🇱🇦', '🇧🇩', '🇱🇰', '🇳🇵', '🇵🇰', '🇦🇫', '🇮🇷', '🇮🇶', '🇸🇦', '🇦🇪', '🇶🇦', '🇰🇼',
      '🇧🇭', '🇴🇲', '🇾🇪', '🇯🇴', '🇱🇧', '🇸🇾', '🇮🇱', '🇵🇸', '🇹🇷', '🇺🇿', '🇰🇿', '🇹🇲',
      '🇰🇬', '🇹🇯', '🇲🇳', '🇧🇳', '🇹🇱', '🇧🇹', '🇲🇻', '🇹🇼', '🇭🇰', '🇲🇴',
      // Oceania
      '🇦🇺', '🇳🇿', '🇫🇯', '🇵🇬', '🇼🇸', '🇹🇴', '🇻🇺', '🇸🇧', '🇰🇮', '🇲🇭', '🇵🇼', '🇫🇲',
      '🇳🇷', '🇹🇻', '🇳🇨', '🇵🇫', '🇬🇺',
    ],
    '♈ Astro': ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓', '🌞', '🌝', '☄️', '🔮', '🌌', '⚛️'],
  };

  void _showCreateSpaceSheet(BuildContext context) {
    final controller = TextEditingController();
    String selectedEmoji = '🏠';
    String selectedCategory = _emojiCategories.keys.first;
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (stateContext, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(stateContext).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(stateContext).size.height * 0.85,
            ),
            height: MediaQuery.of(stateContext).size.height * 0.75, // Fixed height for expansion
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max, // Fill the fixed height
              children: [
                // Fixed header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: context.colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
                      ),
                      // Big emoji preview
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          selectedEmoji,
                          key: ValueKey(selectedEmoji),
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Créer un espace', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                      const SizedBox(height: 4),
                      Text('Choisis un emoji et un nom', style: TextStyle(fontSize: 13, color: context.textSecondary)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Category tabs
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _emojiCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (_, index) {
                      final category = _emojiCategories.keys.elementAt(index);
                      final isActive = category == selectedCategory;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedCategory = category),
                        child: AnimatedContainer(
                          duration: DesignTokens.animFast,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive
                                ? context.semantic.mascot.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? context.semantic.mascot.withValues(alpha: 0.3)
                                  : context.colors.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? context.semantic.mascot : context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Emoji grid - Expanded to fill remaining space
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Bottom padding for footer
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, // Denser grid
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: (_emojiCategories[selectedCategory] ?? []).length,
                    itemBuilder: (_, index) {
                      final emoji = _emojiCategories[selectedCategory]![index];
                      final isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: DesignTokens.animFast,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.semantic.mascot.withValues(alpha: 0.15)
                                : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? context.semantic.mascot : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Name input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: controller,
                    autofocus: false,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Nom de l\'espace (ex: Ski Team)',
                      hintStyle: TextStyle(color: context.textTertiary, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(selectedEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Create button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) {
                           messenger.showSnackBar(const SnackBar(content: Text('Entrez un nom d\'espace')));
                           return;
                        }
                        Navigator.pop(sheetContext);
                        try {
                          await appState.createGroup(name, emoji: selectedEmoji);
                          messenger.showSnackBar(SnackBar(
                            content: Text('$selectedEmoji Espace "$name" créé !'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
                          ));
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: context.semantic.mascot,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Créer mon espace'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupOptionsSheet(BuildContext context, dynamic group) {
     final appState = context.read<AppState>();
     final isOwner = group.createdBy == appState.authService.currentUser?.uid;

     showModalBottomSheet(
       context: context,
       backgroundColor: context.colors.surface,
       shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
       ),
       builder: (ctx) => SafeArea(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const SizedBox(height: 8),
             Container(
               width: 40,
               height: 4,
               decoration: BoxDecoration(
                 color: context.colors.outlineVariant,
                 borderRadius: BorderRadius.circular(2),
               ),
             ),
             Padding(
               padding: const EdgeInsets.all(24),
               child: Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: context.colors.primary.withValues(alpha: 0.1),
                       shape: BoxShape.circle,
                     ),
                     child: Text(group.emoji ?? '🏠', style: const TextStyle(fontSize: 24)),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           group.name,
                           style: GoogleFonts.nunito(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: context.colors.onSurface,
                           ),
                         ),
                         Text(
                           isOwner ? 'Propriétaire' : 'Membre',
                           style: GoogleFonts.inter(
                             fontSize: 14,
                             color: context.colors.onSurfaceVariant,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             const Divider(height: 1),
             ListTile(
               contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
               leading: Icon(Icons.share, color: context.colors.primary),
               title: const Text('Inviter des membres'),
               subtitle: Text('Code: ${group.inviteCode}'),
               onTap: () {
                 Navigator.pop(ctx);
                 Share.share('Rejoins mon espace "${group.name}" sur Mutuals avec le code : ${group.inviteCode}');
               },
             ),
             ListTile(
               contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
               leading: Icon(Icons.edit, color: context.colors.secondary),
               title: const Text('Renommer l\'espace'),
               onTap: () {
                 Navigator.pop(ctx);
                 _showRenameDialog(context, group);
               },
             ),
             if (isOwner)
               ListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                 leading: Icon(Icons.delete_forever, color: context.colors.error),
                 title: Text('Supprimer l\'espace', style: TextStyle(color: context.colors.error)),
                 onTap: () {
                   Navigator.pop(ctx);
                   _showDeleteDialog(context, group);
                 },
               )
             else
               ListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                 leading: Icon(Icons.logout, color: context.colors.error),
                 title: Text('Quitter l\'espace', style: TextStyle(color: context.colors.error)),
                 onTap: () {
                   Navigator.pop(ctx);
                   _showLeaveDialog(context, group);
                 },
               ),
             const SizedBox(height: 24),
           ],
         ),
       ),
     );
  }

  void _showRenameDialog(BuildContext context, dynamic group) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer l\'espace'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nouveau nom'),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
           TextButton(
             onPressed: () {
               final newName = controller.text.trim();
               if (newName.isNotEmpty) {
                 context.read<AppState>().renameGroup(group.id, newName);
               }
               Navigator.pop(ctx);
             },
             child: const Text('Renommer'),
           ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, dynamic group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quitter "${group.name}" ?'),
        content: const Text('Vous n\'aurez plus accès aux données de cet espace.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().leaveGroup(group.id);
            },
            child: Text('Quitter', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer "${group.name}" ?'),
        content: const Text('Cette action est irréversible. Toutes les données seront supprimées pour tous les membres.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<AppState>().deleteGroup(group.id);
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espace supprimé')));
                }
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: Text('Supprimer', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showJoinSpaceSheet(BuildContext context) {
    final controller = TextEditingController();
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: context.colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
              Text('Rejoindre un espace', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.onSurface)),
              const SizedBox(height: 8),
              Text('Demande le code à un membre du groupe.', style: TextStyle(fontSize: 14, color: context.textSecondary)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(color: context.textTertiary, fontSize: 28, letterSpacing: 8),
                  counterText: '',
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    final code = controller.text.trim().toUpperCase();
                    if (code.length != 6) return;
                    Navigator.pop(sheetContext);
                    try {
                      await appState.joinGroup(code);
                      messenger.showSnackBar(SnackBar(
                        content: const Text('🎉 Espace rejoint !'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
                      ));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                    textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Rejoindre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberOptions(BuildContext context, Family group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: context.colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Ajouter un membre', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            _buildOptionTile(
              context,
              icon: Icons.share_rounded,
              title: 'Inviter un proche',
              subtitle: 'Partage le code du groupe',
              onTap: () {
                Navigator.pop(context);
                Share.share('Rejoins mon groupe "${group.name}" sur Famille.io avec le code : ${group.inviteCode}');
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
              icon: Icons.child_care_rounded,
              title: 'Créer un profil administré',
              subtitle: 'Pour un enfant ou quelqu\'un sans téléphone',
              onTap: () {
                Navigator.pop(context);
                _showCreateRestrictedProfileSheet(context, group);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: context.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.outlineVariant),
          ],
        ),
      ),
    );
  }

  void _showCreateRestrictedProfileSheet(BuildContext context, Family group) {
    final nameController = TextEditingController();
    final appState = context.read<AppState>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: context.colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
              Text('Créer un profil', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800)),
              Text('Visible par toi et les membres que tu choisiras', style: TextStyle(color: context.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(sheetContext);
                    
                    final newMember = Member(
                      id: const Uuid().v4(),
                      name: name,
                      gradient: 'from-blue-400 to-indigo-500', // Default
                      relationship: 'Enfant',
                      ownerId: appState.authService.currentUser?.uid, // Restricted
                      tops: [], bottoms: [], shoes: [], accessories: [],
                      wishlist: [], wishHistory: [],
                      topBrands: '', bottomBrands: '', shoeBrands: '',
                      generalTopSize: '', generalBottomSize: '', generalShoeSize: '',
                      fitPreference: FitPreference.regular,
                    );
                    
                    try {
                      await appState.syncService.syncMember(group.id, newMember);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil "$name" créé !')));
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Créer le profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
