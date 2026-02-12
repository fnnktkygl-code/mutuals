import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../services/app_state.dart';
import '../models/member.dart';
import '../models/member_group.dart';
import '../widgets/member_avatar.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';
import '../widgets/glass_card.dart';
import '../widgets/group_editor_modal.dart';
import '../utils/date_utils.dart' as date_utils;

import 'timeline_screen.dart';
import 'member_detail_screen.dart';
import 'settings_screen.dart';
import 'events_screen.dart';
import 'contact_import_screen.dart';
import 'family_management_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Tutorial Keys
  final GlobalKey _familleTitleKey = GlobalKey();
  final GlobalKey _syncBadgeKey = GlobalKey();
  final GlobalKey _addMemberKey = GlobalKey();
  final GlobalKey _groupTabsKey = GlobalKey();
  final GlobalKey _commuTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  void _showTutorial() async {
    if (await StorageService.hasShownHomeTutorial()) return;
    if (!mounted) return;

    // Use a slight delay to ensure UI is fully rendered
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final targets = [
      TutorialService.createTarget(
        key: _familleTitleKey,
        title: "Nom de votre Famille",
        description: "Vous pouvez personnaliser ce nom dans l'onglet 'Famille'.",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      if (context.read<AppState>().hasFamily)
        TutorialService.createTarget(
          key: _syncBadgeKey,
          title: "Status de Synchro",
          description: "Indique que vos modifications sont bien sauvegardées en ligne.",
          align: ContentAlign.bottom,
        ),
      TutorialService.createTarget(
        key: _addMemberKey,
        title: "Ajouter un membre",
        description: "Créez un nouveau profil pour un proche afin de suivre ses tailles et envies.",
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      TutorialService.createTarget(
        key: _groupTabsKey,
        title: "Vos Groupes",
        description: "Filtrez par groupe (Amis, Famille...) ou cliquez sur le '+' pour en créer un nouveau.",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      TutorialService.createTarget(
        key: _commuTabKey,
        title: "Onglet Commu",
        description: "Gérez votre famille, invitez des proches et configurez vos groupes ici.",
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    TutorialService.showTutorial(
      context: context,
      targets: targets,
      onFinish: () => StorageService.setShownHomeTutorial(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
// ... (rest of the file content)

  Widget _buildContent() {
    switch (_currentTab) {
      case 0:
        return _buildMemberList();
      case 1:
        return const TimelineScreen();
      case 2:
        return const FamilyManagementScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildMemberList();
    }
  }

  Widget _buildMemberList() {
    final appState = context.watch<AppState>();
    final members = appState.members;
    final groups = appState.groups;

    return DefaultTabController(
      length: groups.length + 2, // "Tous" + each group + Add button
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Famille.io" branding (smaller, secondary)
                            Row(
                              // key: _familleTitleKey, // Removed from here
                              children: [
                                Text(
                                  'Famille',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.primary.withValues(alpha: 0.8),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      context.colors.primary,
                                      context.colors.primary.withValues(alpha: 0.7),
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    '.io',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                // Sync status badge
                                if (appState.hasFamily) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    key: _syncBadgeKey,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cloud_done, size: 10, color: Colors.green.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SYNC',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.green.shade600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Family Name (Large, Primary)
                            Container(
                              key: _familleTitleKey,
                              child: Text(
                                appState.hasFamily
                                    ? appState.family!.name
                                    : 'Votre Famille',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.onSurface,
                                  letterSpacing: -1.0,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
// ... (rest of _buildMemberList)

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.colors.outlineVariant.withValues(alpha: 0.3),
                              ),
                             boxShadow: [
                                BoxShadow(
                                  color: context.colors.shadow.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EventsScreen()),
                                );
                              },
                              icon: const Icon(Icons.calendar_month),
                              color: context.colors.primary,
                              tooltip: 'Événements',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.colors.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ContactImportScreen()),
                                );
                              },
                              icon: const Icon(Icons.people),
                              color: context.colors.onSurface,
                              tooltip: 'Importer des contacts',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: context.colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un membre...',
                        hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search, color: context.colors.onSurfaceVariant),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                tooltip: 'Effacer la recherche',
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Dynamic group tabs
                  Container(
                    key: _groupTabsKey,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Builder(
                      builder: (tabContext) {
                        return TabBar(
                          isScrollable: true,
                          padding: EdgeInsets.zero,
                          tabAlignment: TabAlignment.start,
                          onTap: (index) {
                            // Handle "Add Group" tap (last item)
                            if (index == groups.length + 1) {
                              // Revert tab selection immediately
                              final tabController = DefaultTabController.of(tabContext);
                              // Calculate current index based on groups length vs previous valid index is tricky if we don't track it.
                              // Safest is to revert to 0 if we assume they clicked it intentionally.
                              // Actually DefaultTabController.of(tabContext) works now!
                              
                              // We need to know previous index. 
                              // Since we don't track inner tab index in state, we might just jump to 0.
                              tabController.animateTo(tabController.previousIndex); 
                              
                              
                              // Open editor
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => GroupEditorModal(
                                  onSave: (name, icon, color) async {
                                    await context.read<AppState>().addGroup(name, icon, color);
                                  },
                                ),
                              );
                            } 
                          },
                          tabs: [
                            const Tab(text: 'Tous'),
                            ...groups.map((g) => Tab(text: '${g.icon} ${g.name}')),
                            const Tab(icon: Icon(Icons.add, size: 20)),
                          ],
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFilteredList(members, null, groups),
                  ...groups.map((g) => _buildFilteredList(members, g.id, groups)),
                  // Dummy view for the "Add" tab
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(List<Member> members, String? groupId, List<MemberGroup> groups) {
    var filteredMembers = groupId == null
        ? members
        : members.where((m) => m.groupIds.contains(groupId)).toList();

    if (_searchQuery.isNotEmpty) {
      filteredMembers = filteredMembers.where((m) {
        return m.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Check for initial loading state
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isSyncing && members.isEmpty) {
      return _buildSkeletonList();
    }

    final group = groupId != null 
        ? groups.firstWhere((g) => g.id == groupId, orElse: () => MemberGroup(id: '', name: '', icon: '', color: '', order: 0, isDefault: false))
        : null;

    if (group != null && filteredMembers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Text(
                  group.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groupe ${group.name}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.colors.onSurface,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${filteredMembers.length} membre${filteredMembers.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildMemberListView(filteredMembers, groups, group),
          ),
        ],
      );
    }
    
    return _buildMemberListView(filteredMembers, groups, null);
  }

  Widget _buildMemberListView(List<Member> filteredMembers, List<MemberGroup> groups, MemberGroup? group) {

    if (filteredMembers.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off,
          title: 'Aucun résultat',
          subtitle: 'Aucun membre ne correspond à "$_searchQuery"',
          showAddButton: false, 
        );
      } else if (group != null) {
        return _buildEmptyState(
          icon: Icons.people_outline,
          title: 'Groupe vide',
          subtitle: 'Aucun membre dans ${group.name}',
          showAddButton: true,
        );
      } else {
        return _buildEmptyState(
          icon: Icons.family_restroom,
          title: 'Bienvenue !',
          subtitle: 'Ajoutez votre premier membre pour commencer.',
          showAddButton: true,
        );
      }
    }

    final currentMonthKey = date_utils.DateUtils.getCurrentMonthKey();
    // itemCount = members + 1 add_button
    final itemCount = filteredMembers.length + 1;

    // Find group info for badge display
    List<MemberGroup> findMemberGroups(List<String> ids) {
       return groups.where((g) => ids.contains(g.id)).toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<AppState>(context, listen: false).refreshData();
      },
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Last item = add member button
          if (index == filteredMembers.length) {
            return _buildAddMemberButton();
          }

          final member = filteredMembers[index];
          final hasCurrentWish = member.wishHistory
              .any((w) => w.monthKey == currentMonthKey && w.text.isNotEmpty);

          String? ageString;
          if (member.birthday != null) {
            final age = date_utils.DateUtils.calculateCustomAge(member.birthday!);
            ageString = '$age ans';
          }

          final memberGroups = findMemberGroups(member.groupIds);

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GlassCard(
              padding: const EdgeInsets.all(0),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemberDetailScreen(memberId: member.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Large Avatar
                    Hero(
                      tag: 'member_${member.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.shadow.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: MemberAvatar(
                          member: member,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* Name */
                          Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.colors.onSurface,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // Group Chips
                          if (memberGroups.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: memberGroups.map((g) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _parseColor(g.color).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _parseColor(g.color).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(g.icon, style: const TextStyle(fontSize: 10)),
                                        const SizedBox(width: 4),
                                        Text(
                                          g.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _parseColor(g.color),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          
                          // Context Chips (Age + Status)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Age Chip
                              if (ageString != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.colors.outline.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Text(
                                    ageString,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                
                              // Family Badge (only for real users who joined via code)
                              if (member.relationship.toLowerCase() == 'moi' && !member.isOwner)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.colors.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.diversity_3, size: 12, color: context.colors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Famille',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Wish Status Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: hasCurrentWish 
                                      ? const Color(0xFFFBBF24).withValues(alpha: 0.15)
                                      : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: hasCurrentWish 
                                        ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      hasCurrentWish ? Icons.star_rounded : Icons.do_not_disturb,
                                      size: 14,
                                      color: hasCurrentWish 
                                          ? const Color(0xFFD97706)
                                          : context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      hasCurrentWish ? 'Envie dispo' : "Pas d'envie ce mois",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: hasCurrentWish 
                                            ? const Color(0xFFD97706)
                                            : context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showAddButton,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<AppState>(context, listen: false).refreshData();
      },
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (showAddButton) ...[
                const SizedBox(height: 32),
                _buildAddMemberButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // _getCategoryIcon removed — replaced by inline group emoji badge in _buildFilteredList

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Liste', 0),
          _buildNavItem(Icons.grid_view, 'Année', 1),
          _buildNavItem(Icons.diversity_3, 'Commu', 2, key: _commuTabKey),
          _buildNavItem(Icons.settings, 'Options', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {Key? key}) {
    final isSelected = _currentTab == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentTab = index);
        if (index == 0) {
           // Re-check tutorial when returning to home tab (e.g. after reset in settings)
           WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
        }
      },
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
                size: 24,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSkeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Skeleton(width: 80, height: 80, borderRadius: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(width: 150, height: 24, borderRadius: 6),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Skeleton(width: 60, height: 24, borderRadius: 12),
                          SizedBox(width: 8),
                          Skeleton(width: 80, height: 24, borderRadius: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MemberDetailScreen(memberId: null),
          ),
        );
      },
      child: Semantics(
        button: true,
        label: 'Ajouter un profil',
        child: Container(
          key: _addMemberKey,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.2),
              width: 2,
              style: BorderStyle.solid,
            ),
            color: context.colors.surface.withValues(alpha: 0.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ajouter un profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return context.colors.primary;
    }
  }
}
