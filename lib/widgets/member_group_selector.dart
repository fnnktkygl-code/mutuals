import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'group_editor_modal.dart';

/// Group selector pill list for member editing
class MemberGroupSelector extends StatelessWidget {
  final Member member;
  final ValueChanged<Member> onMemberChanged;

  const MemberGroupSelector({
    super.key,
    required this.member,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<AppState>().groups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Groupes (max 3)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.colors.outline),
            ),
             Text(
              '${member.groupIds.length}/3',
              style: TextStyle(fontSize: 12, color: context.colors.outlineVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...groups.map((group) {
              final isSelected = member.groupIds.contains(group.id);
              return FilterChip(
                label: Text(group.name),
                avatar: Text(group.icon),
                selected: isSelected,
                onSelected: (bool selected) {
                  final currentIds = List<String>.from(member.groupIds);
                  if (selected) {
                    if (currentIds.length < 3) {
                      currentIds.add(group.id);
                      onMemberChanged(member.copyWith(groupIds: currentIds));
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Maximum 3 groupes par membre")),
                      );
                    }
                  } else {
                    currentIds.remove(group.id);
                    onMemberChanged(member.copyWith(groupIds: currentIds));
                  }
                },
                backgroundColor: context.colors.surfaceContainerHighest,
                selectedColor: context.colors.primaryContainer,
                checkmarkColor: context.colors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? context.colors.primary : context.colors.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Créer'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => GroupEditorModal(
                    onSave: (name, icon, color) async {
                      final newGroup = await context.read<AppState>().addGroup(name, icon, color);
                      final currentIds = List<String>.from(member.groupIds);
                      if (currentIds.length < 3) {
                        currentIds.add(newGroup.id);
                        onMemberChanged(member.copyWith(groupIds: currentIds));
                      }
                    },
                  ),
                );
              },
              backgroundColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
              side: BorderSide(
                color: context.colors.primary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
              labelStyle: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

