import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/fit_preference.dart';
import '../theme/app_theme.dart';

/// Fit preference selector (slim/regular/oversize)
class FitPreferenceSelector extends StatelessWidget {
  final Member member;
  final bool isEditing;
  final ValueChanged<Member> onMemberChanged;

  const FitPreferenceSelector({
    super.key,
    required this.member,
    required this.isEditing,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Préférence de coupe',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditing)
          Row(
            children: FitPreference.values.map((fit) {
              final isSelected = member.fitPreference == fit;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onMemberChanged(member.copyWith(fitPreference: fit)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: AppTheme.selectionDecoration(isSelected, context),
                      child: Center(
                        child: Text(
                          fit.label,
                          style: AppTheme.selectionTextStyle(isSelected, context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        else
          Row(
            children: [
              const Icon(Icons.cut, size: 12),
              const SizedBox(width: 4),
              Text(
                'Coupe : ${member.fitPreference.label}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        if (member.fitPreference == FitPreference.oversize)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'ℹ️ Pour l\'oversize, vérifier s\'il faut prendre une taille en dessous.',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
