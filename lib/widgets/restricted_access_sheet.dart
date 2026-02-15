import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../services/app_state.dart';
import '../theme/design_tokens.dart';
import '../theme/app_theme.dart';

class RestrictedAccessSheet extends StatefulWidget {
  final Member member;

  const RestrictedAccessSheet({super.key, required this.member});

  static Future<void> show(BuildContext context, Member member) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RestrictedAccessSheet(member: member),
    );
  }

  @override
  State<RestrictedAccessSheet> createState() => _RestrictedAccessSheetState();
}

class _RestrictedAccessSheetState extends State<RestrictedAccessSheet> {
  late List<String> _sharedWith;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sharedWith = List.from(widget.member.sharedWith);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final appState = context.read<AppState>();
    final updatedMember = widget.member.copyWith(sharedWith: _sharedWith);
    
    try {
      // Find the group this member belongs to. 
      // For now, we assume current group or we search.
      String? groupId = appState.currentGroupId;
      if (groupId == 'all' || groupId == null) {
          // Fallback: try to find which group this member is in
          final groups = appState.getGroupIdsForMember(widget.member.id);
          if (groups.isNotEmpty) groupId = groups.first;
      }

      if (groupId != null && groupId != 'all') {
         await appState.syncService.syncMember(groupId, updatedMember);
         if (mounted) Navigator.pop(context);
         // Show success
      } else {
         throw Exception("Groupe introuvable");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Get all REAL users (not restricted profiles) from the group to share with
    final potentialSharers = appState.members.where((m) {
       return m.ownerId == null && m.id != appState.authService.currentUser?.uid;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: context.colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(
            'Gérer l\'accès',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Qui peut voir le profil de ${widget.member.name} ?',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          if (potentialSharers.isEmpty)
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 20),
               child: Text(
                 "Aucun autre membre dans le groupe avec qui partager.",
                 style: TextStyle(color: context.textTertiary),
               ),
             ),

          ...potentialSharers.map((m) {
            final isShared = _sharedWith.contains(m.id);
            return CheckboxListTile(
              title: Text(m.name, style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface)),
              value: isShared,
              activeColor: context.colors.primary,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _sharedWith.add(m.id);
                  } else {
                    _sharedWith.remove(m.id);
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            );
          }),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}
