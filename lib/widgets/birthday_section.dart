import 'package:flutter/material.dart';
import '../models/member.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/zodiac_utils.dart';

/// Birthday display and date picker section
class BirthdaySection extends StatelessWidget {
  final Member member;
  final bool isEditing;
  final ValueChanged<Member> onMemberChanged;

  const BirthdaySection({
    super.key,
    required this.member,
    required this.isEditing,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing && member.birthday == null) return const SizedBox.shrink();

    final showAge = isEditing || member.isOwner || (member.shareAccess['age'] ?? true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing) ...[
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anniversaire',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.onSurface),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: member.birthday ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      onMemberChanged(member.copyWith(birthday: date));
                    }
                  },
                  icon: const Icon(Icons.cake),
                  label: Text(member.birthday == null
                      ? 'Ajouter une date'
                      : '${member.birthday!.day}/${member.birthday!.month}/${member.birthday!.year}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.onSurface,
                    side: BorderSide(color: context.colors.outline.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
          ),
        ] else if (member.birthday != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cake, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Anniversaire le ${member.birthday!.day} ${date_utils.DateUtils.formatMonthLong('${DateTime.now().year}-${member.birthday!.month.toString().padLeft(2, '0')}').split(' ')[0]}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showAge)
                      Column(
                        children: [
                          Text(
                            '${member.age + 1} ans',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Bientôt',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text(
                            '?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Age caché',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    Container(
                      height: 40, width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Column(
                      children: [
                        Text(
                          ZodiacUtils.getZodiacEmoji(member.birthday!),
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          ZodiacUtils.getZodiacSign(member.birthday!).split(' ')[1],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40, width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Column(
                      children: [
                        Text(
                          'J-${member.daysUntilBirthday}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Compte à rebours',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (member.daysUntilBirthday <= 30)
            Text(
              '🎂 Prochain dans ${member.daysUntilBirthday} jours (${member.age + 1} ans)',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: context.colors.primary,
              ),
            ),
        ],
      ],
    );
  }
}
