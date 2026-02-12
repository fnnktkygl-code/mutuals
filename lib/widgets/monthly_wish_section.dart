import 'package:flutter/material.dart';
import '../models/member.dart';

import '../widgets/badge.dart' as app_badge;

import '../utils/date_utils.dart' as date_utils;

/// Monthly wish text field + display
class MonthlyWishSection extends StatelessWidget {
  final Member member;
  final bool isEditing;
  final TextEditingController wishController;

  const MonthlyWishSection({
    super.key,
    required this.member,
    required this.isEditing,
    required this.wishController,
  });

  @override
  Widget build(BuildContext context) {
    final currentKey = date_utils.DateUtils.getCurrentMonthKey();
    final currentWish = member.wishHistory.where((w) => w.monthKey == currentKey).firstOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // Blue to Cyan
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 24, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                date_utils.DateUtils.formatMonthLong(currentKey).toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (isEditing)
                app_badge.AppBadge(
                  text: 'J-${date_utils.DateUtils.getDaysRemaining()}',
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  textColor: Colors.white,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEditing)
            TextField(
              controller: wishController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Une envie ce mois-ci ? (ex: Livre, Resto...)',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            )
          else
            Text(
              currentWish?.text.isNotEmpty == true 
                  ? '"${currentWish!.text}"' 
                  : '"Pas encore d\'envie définie pour ce mois-ci."',
              style: TextStyle(
                fontSize: 18, // Larger text
                fontWeight: currentWish?.text.isNotEmpty == true ? FontWeight.w600 : FontWeight.normal,
                fontStyle: currentWish?.text.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                color: Colors.white.withValues(alpha: currentWish?.text.isNotEmpty == true ? 1.0 : 0.8),
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
