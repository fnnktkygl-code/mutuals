import 'package:flutter/material.dart';
import '../models/member.dart';
import '../widgets/glass_card.dart';
import '../widgets/tag_editor.dart';
import '../theme/app_theme.dart';

/// Tags section with gift suggestion display
class TagsSection extends StatelessWidget {
  final Member member;
  final bool isEditing;
  final ValueChanged<Member> onMemberChanged;

  const TagsSection({
    super.key,
    required this.member,
    required this.isEditing,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            TagEditor(
              tags: member.tags,
              onChanged: (newTags) => onMemberChanged(member.copyWith(tags: newTags)),
            )
          else ...[
            Text(
              '🏷️ Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (member.tags.isEmpty)
              Text(
                'Aucun tag défini',
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: member.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            // Gift suggestions based on tags
            if (member.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '🎁 Idées cadeaux',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: getGiftSuggestions(member.tags).take(6).map((suggestion) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
