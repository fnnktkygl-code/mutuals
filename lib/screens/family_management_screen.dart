import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/member_group.dart';
import '../widgets/group_editor_modal.dart';
import '../services/storage_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/tutorial_service.dart';

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  final _familyNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;

  String? _error;

  final GlobalKey _familyNameKey = GlobalKey();
  final GlobalKey _inviteCodeKey = GlobalKey();
  final GlobalKey _groupsKey = GlobalKey();
  final GlobalKey _createFamilyKey = GlobalKey();
  final GlobalKey _joinFamilyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  void _showTutorial() async {
    if (await StorageService.hasShownFamilyTutorial()) return;
    if (!mounted) return;

    final targets = [
      if (context.read<AppState>().hasFamily) ...[
        TutorialService.createTarget(
          key: _familyNameKey,
          title: "Nom de la Communauté",
          description: "Le nom de votre famille/communauté. Visible par tous les membres.",
          align: ContentAlign.bottom,
        ),
        TutorialService.createTarget(
          key: _inviteCodeKey,
          title: "Code d'invitation",
          description: "Partagez ce code pour que vos proches rejoignent votre communauté.",
          align: ContentAlign.bottom,
        ),
      ],
      if (!context.read<AppState>().hasFamily) ...[
        TutorialService.createTarget(
          key: _createFamilyKey,
          title: "Créer une Communauté",
          description: "Démarrez votre propre espace familial pour inviter vos proches.",
          align: ContentAlign.bottom,
        ),
        TutorialService.createTarget(
          key: _joinFamilyKey,
          title: "Rejoindre une Communauté",
          description: "Entrez le code reçu d'un membre de votre famille pour vous connecter.",
          align: ContentAlign.top,
        ),
      ],
      TutorialService.createTarget(
        key: _groupsKey,
        title: "Gérer les Groupes",
        description: "Créez des groupes (ex: Amis, Famille) pour organiser vos contacts.",
        align: ContentAlign.top,
      ),
    ];

    TutorialService.showTutorial(
      context: context,
      targets: targets,
      onFinish: () => StorageService.setShownFamilyTutorial(),
    );
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ma Communauté',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: context.colors.onSurface,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez votre famille et vos groupes.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              if (appState.hasFamily)
                _buildConnectedState(context, appState)
              else
                _buildDisconnectedState(context, appState),

              const SizedBox(height: 32),
              
              // Groups Section
              _buildGroupsSection(context, appState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, AppState appState) {
    final family = appState.family!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '🏠 Votre Famille'),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                key: _familyNameKey,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.family_restroom, size: 32, color: context.colors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          family.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        Text(
                          '${family.memberUids.length} membre(s) synchronisé(s)',
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
              const SizedBox(height: 20),
              Container(
                key: _inviteCodeKey,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'CODE D\'INVITATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          family.inviteCode,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            fontFamily: 'monospace',
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: family.inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copié !')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copier',
                          style: IconButton.styleFrom(
                            foregroundColor: context.colors.primary,
                            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Share.share('Rejoins ma famille sur Famille.io avec le code : ${family.inviteCode}');
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Inviter un proche'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showLeaveDialog(context, appState),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Quitter la famille'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(color: context.colors.error.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectedState(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '☁️ Synchronisation'),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour partager les données avec vos proches.',
          style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 16),
        
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: context.colors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: TextStyle(color: context.colors.error, fontSize: 13))),
              ],
            ),
          ),

        // Create
        GlassCard(
          key: _createFamilyKey,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Créer une famille', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
              const SizedBox(height: 12),
              TextField(
                controller: _familyNameController,
                decoration: InputDecoration(
                  hintText: 'Nom (ex: Les Dupont)',
                  prefixIcon: const Icon(Icons.add_home),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isCreating ? null : () => _createFamily(appState),
                  child: Text(_isCreating ? 'Création...' : 'Créer'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Row(
           children: [
             Expanded(child: Divider(color: context.colors.outlineVariant)),
             Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OU", style: TextStyle(color: context.colors.outline))),
             Expanded(child: Divider(color: context.colors.outlineVariant)),
           ],
        ),
        const SizedBox(height: 16),

        // Join
        GlassCard(
          key: _joinFamilyKey,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rejoindre une famille', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
              const SizedBox(height: 12),
              TextField(
                controller: _inviteCodeController,
                decoration: InputDecoration(
                  hintText: 'Code d\'invitation',
                  prefixIcon: const Icon(Icons.key),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isJoining ? null : () => _joinFamily(appState),
                  child: Text(_isJoining ? 'Connexion...' : 'Rejoindre'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsSection(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          key: _groupsKey,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, '👥 Mes Groupes'),
            IconButton(
              onPressed: () => _showGroupEditor(context, appState, null),
              icon: const Icon(Icons.add_circle),
              color: context.colors.primary,
              tooltip: 'Ajouter un groupe',
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...appState.groups.map((group) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () => _showGroupEditor(context, appState, group),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(group.color, context),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(group.icon, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface),
                      ),
                      if (group.isDefault)
                        Text('Par défaut', style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showGroupEditor(context, appState, group),
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        )),
        if (appState.groups.isEmpty)
           Padding(
             padding: const EdgeInsets.all(24.0),
             child: Center(
               child: Text(
                 "Aucun groupe personnalisé.\nCréez des groupes (ex: 'Amis', 'Collègues') pour filtrer vos proches.",
                 textAlign: TextAlign.center,
                 style: TextStyle(color: context.colors.onSurfaceVariant),
               ),
             ),
           ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: context.colors.onSurface,
        letterSpacing: -0.5,
      ),
    );
  }

  // Logic Helpers
  Future<void> _createFamily(AppState appState) async {
    final name = _familyNameController.text.trim();
    if (name.isEmpty) return;
    setState(() { _isCreating = true; _error = null; });
    try {
      await appState.createFamily(name);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _joinFamily(AppState appState) async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.length != 6) return;
    setState(() { _isJoining = true; _error = null; });
    try {
      await appState.joinFamily(code);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showLeaveDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter la famille ?'),
        content: const Text('Vous ne recevrez plus les mises à jour.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.leaveFamily();
            },
            child: Text('Quitter', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showGroupEditor(BuildContext context, AppState appState, MemberGroup? group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupEditorModal(
        groupId: group?.id,
        initialName: group?.name,
        initialIcon: group?.icon,
        initialColor: group?.color,
        onSave: (name, icon, color) async {
          if (group == null) {
            await appState.addGroup(name, icon, color);
          } else {
            await appState.updateGroup(group.id, group.copyWith(name: name, icon: icon, color: color));
          }
        },
      ),
    );
  }

  Color _parseColor(String hexColor, BuildContext context) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return context.colors.primary;
    }
  }
}
