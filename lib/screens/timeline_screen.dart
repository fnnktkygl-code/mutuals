import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../services/app_state.dart';
import '../models/member.dart';
import '../models/monthly_wish.dart';
import '../widgets/member_avatar.dart';
import '../widgets/filou_bubble.dart';
import '../theme/filou_state.dart';
import '../utils/date_utils.dart' as date_utils;
import '../theme/app_theme.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _timelineListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  void _showTutorial() async {
    if (await StorageService.hasShownTimelineTutorial()) return;

    if (!mounted) return;

    final targets = [
      TutorialService.createTarget(
        key: _titleKey,
        title: "Calendrier des Envies 🎁",
        description: "Toutes les envies et anniversaires de tes proches, mois par mois. C'est moi, Filou, qui t'accompagne !",
        align: ContentAlign.bottom,
        filou: FilouState.gift,
        stepNumber: 1,
        totalSteps: 2,
      ),
      TutorialService.createTarget(
        key: _timelineListKey,
        title: "Swipe pour explorer 👉",
        description: "Fais défiler horizontalement pour découvrir les envies de chaque mois. Clique sur une carte pour voir les détails !",
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
        filou: FilouState.happy,
        stepNumber: 2,
        totalSteps: 2,
        isLast: true,
      ),
    ];

    TutorialService.showTutorial(
      context: context,
      targets: targets,
      onFinish: () => StorageService.setShownTimelineTutorial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Members are already filtered by current group in AppState
    final members = appState.members;
    final currentGroup = appState.currentGroup;

    final months = date_utils.DateUtils.getLast12MonthsKeysReverse();
    final currentKey = date_utils.DateUtils.getCurrentMonthKey();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  key: _titleKey,
                  children: [
                    Text(
                      'Calendrier ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: context.colors.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'des Envies',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: context.colors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentGroup != null 
                      ? 'Pour l\'espace "${currentGroup.name}"'
                      : 'Sélectionnez un espace pour voir le calendrier.',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: _buildTimelineList(context, members, months, currentKey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(
    BuildContext context,
    List<Member> members,
    List<String> allMonths,
    String currentKey,
  ) {
    if (members.isEmpty) {
       return const Center(
         child: FilouBubble(
           state: FilouState.gift,
           message: 'Pas encore d\'envies ce mois-ci !\nAjoute les tailles et envies de tes proches.',
         ),
       );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        // Only assign key to first item for tutorial purpose
        final key = index == 0 ? _timelineListKey : null;

        // Dynamic Filtering Logic
        // 1. Always keep current month
        // 2. Keep months with Wishes
        // 3. Keep months with Birthdays
        final relevantMonths = allMonths.where((mKey) {
          if (mKey == currentKey) return true;
          
          final hasWish = member.wishHistory.any((w) => w.monthKey == mKey && w.text.isNotEmpty);
          if (hasWish) return true;

          if (member.birthday != null) {
            final monthDate = date_utils.DateUtils.getMonthFromKey(mKey);
            if (monthDate.month == member.birthday!.month) return true;
          }
          return false;
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  MemberAvatar(
                    member: member,
                    size: 32, 
                  ),
                  const SizedBox(width: 12),
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                key: key,
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: relevantMonths.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, mIndex) {
                    final monthKey = relevantMonths[mIndex];
                    final wish = member.wishHistory
                            .cast<MonthlyWish?>()
                            .firstWhere(
                              (w) => w?.monthKey == monthKey,
                              orElse: () => null,
                            );
                    final isCurrent = monthKey == currentKey;
                    
                    return _buildWishCard(context, wish, monthKey, isCurrent, member);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishCard(BuildContext context, MonthlyWish? wish, String monthKey, bool isCurrent, Member member) {
    final hasWish = wish != null && wish.text.isNotEmpty;
    final isGifted = wish?.status == WishStatus.gifted;
    final monthDate = date_utils.DateUtils.getMonthFromKey(monthKey);
    final isBirthday = member.birthday != null && member.birthday!.month == monthDate.month;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent 
            ? context.colors.surface 
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? context.colors.primary
              : context.colors.outlineVariant.withValues(alpha: 0.5),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date_utils.DateUtils.formatMonthShort(monthKey).toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCurrent
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
              if (hasWish)
                Icon(
                  isGifted ? Icons.check_circle : Icons.auto_awesome,
                  size: 14,
                  color: isGifted ? const Color(0xFF16A34A) : context.colors.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Wish or Birthday content
          if (wish != null)
            Expanded(
              child: Text(
                wish.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            )
          else if (isBirthday)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      const Icon(Icons.cake, size: 16, color: Color(0xFFEC4899)),
                      const SizedBox(width: 8),
                      // Provide a default age if calculation fails or is complex
                      Text(
                        'Anniv !', // Simplify age calc for now or import helper
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      'Trouver un cadeau 🎁',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: context.colors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Text(
                'Rien de prévu',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
