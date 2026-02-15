import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart'; // Colors extension
import '../widgets/glass_card.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  // State for Create Group
  String _selectedEmoji = '🏠';
  String _selectedBackground = 'from-blue-400 to-blue-600';
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final List<String> _availableEmojis = ['🏠', '❤️', '👨‍👩‍👧‍👦', '🌟', '🐶', '🐱', '🚀', '🏰', '🏖️', '🏔️'];
  final List<String> _availableBackgrounds = [
    'from-blue-400 to-blue-600',
    'from-purple-400 to-purple-600',
    'from-green-400 to-green-600',
    'from-orange-400 to-orange-600',
    'from-pink-400 to-pink-600',
    'from-indigo-400 to-indigo-600',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _groupNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentGroup = appState.currentGroup;

    return Scaffold(
      backgroundColor: context.colors.surface,
      // FAB Removed
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Espace',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: context.colors.onSurface,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez vos espaces et rejoignez-en de nouveaux.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // 1. ACTIVE GROUP SETTINGS
              if (currentGroup != null) ...[
                _buildSectionTitle(context, 'Espace Actif'),
                const SizedBox(height: 16),
                _buildActiveSpaceCard(context, currentGroup, appState),
                const SizedBox(height: 32),
              ],

              // 2. MY SPACES LIST
              if (appState.visibleGroups.isNotEmpty) ...[
                _buildSectionTitle(context, 'Mes Espaces'),
                const SizedBox(height: 16),
                _buildSpacesList(context, appState),
                const SizedBox(height: 32),
              ],

              // 3. CREATE / JOIN
              _buildSectionTitle(context, 'Ajouter un Espace'),
              const SizedBox(height: 16),
              _buildCreateJoinSection(context, appState),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ... [Keep _buildSectionTitle, _buildActiveSpaceCard, _buildSpacesList same if untouched, but I need to update them to show emoji/bg]
  // I'll update _buildActiveSpaceCard and _buildSpacesList in a separate call or same if I can fit it. 
  // I'll focus on removing FAB and adding Picker UI first to keep it clean.
  // Actually, I should update the "create" logic here.

  Widget _buildCreateJoinSection(BuildContext context, AppState appState) {
    return Column(
      children: [
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: context.colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Créer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name Input
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Nom (ex: Famille)',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),
              
              // Emoji Picker
              Text("Icône", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _availableEmojis[index];
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? context.colors.primary.withValues(alpha: 0.2) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: context.colors.primary) : null,
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Background Picker
              Text("Couleur", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableBackgrounds.length,
                  itemBuilder: (context, index) {
                    final bg = _availableBackgrounds[index];
                    final isSelected = _selectedBackground == bg;
                    // Extract start color for preview
                    
                    // Simple mapping or strict parsing?
                    // Let's just use a mapped color for preview
                    Color previewColor = Colors.grey;
                    if (bg.contains('blue')) {
                      previewColor = Colors.blue;
                    } else if (bg.contains('purple')) {
                      previewColor = Colors.purple;
                    } else if (bg.contains('green')) {
                      previewColor = Colors.green;
                    } else if (bg.contains('orange')) {
                      previewColor = Colors.orange;
                    } else if (bg.contains('pink')) {
                      previewColor = Colors.pink;
                    } else if (bg.contains('indigo')) {
                      previewColor = Colors.indigo;
                    }

                    return GestureDetector(
                      onTap: () => setState(() => _selectedBackground = bg),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: context.colors.onSurface, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : () => _createGroup(appState),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isLoading ? 'Création...' : 'Créer l\'espace'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Join
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.login, color: context.colors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text('Rejoindre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCodeController,
                      decoration: InputDecoration(
                        hintText: 'Code (6 lettres)',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        counterText: "",
                      ),
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : () => _joinGroup(appState),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                         : const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Logic Helpers
  Future<void> _createGroup(AppState appState) async {
    final name = _groupNameController.text.trim();
    if (name.isEmpty) return;
    
    setState(() { _isLoading = true; _error = null; });
    FocusScope.of(context).unfocus();
    
    try {
      await appState.createGroup(
        name,
        emoji: _selectedEmoji,
        background: _selectedBackground,
      );
      _groupNameController.clear();
      // Reset defaults?
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Espace "$name" créé !')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinGroup(AppState appState) async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.length != 6) return;
    
    setState(() { _isLoading = true; _error = null; });
    FocusScope.of(context).unfocus();
    
    try {
      await appState.joinGroup(code);
      _inviteCodeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espace rejoint !')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLeaveDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter cet espace ?'),
        content: const Text('Vous n\'aurez plus accès aux membres et listes de cet espace.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (appState.currentGroup != null) {
                appState.leaveGroup(appState.currentGroup!.id);
              }
            },
            child: Text('Quitter', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet espace ?'),
        content: const Text('Cette action est irréversible. Tous les membres seront retirés et les données supprimées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              try {
                if (appState.currentGroup != null) {
                  await appState.deleteGroup(appState.currentGroup!.id);
                }
                messenger.showSnackBar(
                  const SnackBar(content: Text('Espace supprimé.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: Text('Supprimer', style: TextStyle(color: context.colors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: context.colors.onSurface,
      ),
    );
  }

  Widget _buildActiveSpaceCard(BuildContext context, dynamic group, AppState appState) {
    // Helper to extract color from gradient string for tinting
    Color tintColor = context.colors.primary;
    if (group.background != null) {
      if (group.background!.contains('blue')) {
        tintColor = Colors.blue;
      } else if (group.background!.contains('purple')) {
        tintColor = Colors.purple;
      } else if (group.background!.contains('green')) {
        tintColor = Colors.green;
      } else if (group.background!.contains('orange')) {
        tintColor = Colors.orange;
      } else if (group.background!.contains('pink')) {
        tintColor = Colors.pink;
      } else if (group.background!.contains('indigo')) {
        tintColor = Colors.indigo;
      }
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tintColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  group.emoji ?? '🏠',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      '${group.memberUids.length} membre(s)',
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
                      group.inviteCode,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                        color: tintColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: group.inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copié !')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copier',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Share.share('Rejoins mon espace "${group.name}" sur Mutuals avec le code : ${group.inviteCode}');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: tintColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Inviter'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (group.createdBy == appState.authService.currentUser?.uid)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context, appState),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Supprimer cet espace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(color: context.colors.error.withValues(alpha: 0.5)),
                  backgroundColor: context.colors.error.withValues(alpha: 0.05),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLeaveDialog(context, appState),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Quitter cet espace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(color: context.colors.error.withValues(alpha: 0.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpacesList(BuildContext context, AppState appState) {
    // Only show visible groups
    final visibleGroups = appState.visibleGroups;
    
    return Column(
      children: visibleGroups.map((group) {
        final isSelected = appState.currentGroupId == group.id;
        
        // Helper to extract color from gradient string for list items
        Color tintColor = context.colors.primary;
        if (group.background != null) {
          if (group.background!.contains('blue')) {
            tintColor = Colors.blue;
          } else if (group.background!.contains('purple')) {
            tintColor = Colors.purple;
          } else if (group.background!.contains('green')) {
            tintColor = Colors.green;
          } else if (group.background!.contains('orange')) {
            tintColor = Colors.orange;
          } else if (group.background!.contains('pink')) {
            tintColor = Colors.pink;
          } else if (group.background!.contains('indigo')) {
            tintColor = Colors.indigo;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () => appState.selectGroup(group.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? tintColor.withValues(alpha: 0.15)
                    : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? tintColor.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Text(group.emoji ?? '🏠', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? tintColor : context.colors.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tintColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Actif",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
