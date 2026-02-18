import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/member.dart';
import '../widgets/member_avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/filou_bubble.dart';
import '../utils/zodiac_utils.dart';
import '../theme/filou_state.dart';
import '../theme/app_theme.dart';

/// Event types supported
enum EventType {
  birthday,
  christmas,
  valentines,
  mothersDay,
  fathersDay,
  newYear,
  custom,
}

/// Event model
class CalendarEvent {
  final String title;
  final String subtitle;
  final DateTime date;
  final EventType type;
  final Member? member;
  final IconData icon;
  final Color color;

  CalendarEvent({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    this.member,
    required this.icon,
    required this.color,
  });

  int get daysUntil {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, date.month, date.day);
    if (thisYear.isBefore(now)) {
      return DateTime(now.year + 1, date.month, date.day).difference(now).inDays;
    }
    return thisYear.difference(now).inDays;
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  String? _selectedGroupId;
  DateTime? _selectedDate;

  // Fixed holidays — uses current year for correct daysUntil calculation
  static List<CalendarEvent> get _holidays {
    final year = DateTime.now().year;
    return [
      CalendarEvent(
        title: 'Nouvel An',
        subtitle: 'Bonne année ! 🎊',
        date: DateTime(year, 1, 1),
        type: EventType.newYear,
        icon: Icons.celebration,
        color: Colors.amber,
      ),
      CalendarEvent(
        title: 'Saint-Valentin',
        subtitle: "Fête des amoureux 💕",
        date: DateTime(year, 2, 14),
        type: EventType.valentines,
        icon: Icons.favorite,
        color: Colors.pink,
      ),
      CalendarEvent(
        title: 'Fête des Mères',
        subtitle: 'Gâtez-la ! 💐',
        date: DateTime(year, 5, 26),
        type: EventType.mothersDay,
        icon: Icons.local_florist,
        color: Colors.purple,
      ),
      CalendarEvent(
        title: 'Fête des Pères',
        subtitle: 'Pensez à lui ! 👔',
        date: DateTime(year, 6, 16),
        type: EventType.fathersDay,
        icon: Icons.sports_golf,
        color: Colors.blue,
      ),
      CalendarEvent(
        title: 'Noël',
        subtitle: 'Joyeuses fêtes ! 🎄',
        date: DateTime(year, 12, 25),
        type: EventType.christmas,
        icon: Icons.card_giftcard,
        color: AccentColor.red.color,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CalendarEvent> _getAllEvents(List<Member> members) {
    final events = <CalendarEvent>[];
    
    // Add holidays
    events.addAll(_holidays);
    
    // Add birthdays from members
    for (final member in members) {
      if (member.birthday != null) {
        // Show all members since list is already filtered by AppState
        events.add(CalendarEvent(
          title: member.name,
          subtitle: '${member.age + 1} ans • ${ZodiacUtils.getZodiacSign(member.birthday!)}',
          date: member.birthday!,
          type: EventType.birthday,
          member: member,
          icon: Icons.cake,
          color: context.colors.primary,
        ));
      }
    }
    
    // Sort by days until event
    events.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    
    return events;
  }

  List<CalendarEvent> _getEventsForDate(List<CalendarEvent> allEvents, DateTime date) {
    return allEvents.where((e) => 
      e.date.month == date.month && e.date.day == date.day
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            final allEvents = _getAllEvents(appState.members);
            
            if (allEvents.isEmpty) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        Text('Événements ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: context.colors.onSurface, letterSpacing: -1)),
                        Text('& Anniv', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: context.colors.primary, letterSpacing: -1)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: FilouBubble(
                        state: FilouState.celebrating,
                        message: 'Rien à l\'horizon pour l\'instant !\nAjoute les anniversaires de tes proches.',
                      ),
                    ),
                  ),
                ],
              );
            }
            
            return Column(
              children: [
                // Header — styled like other tabs (no back button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Text(
                        'Événements ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: context.colors.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        '& Anniv',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: context.colors.primary,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '📅 Calendrier'),
                      Tab(text: '📋 Liste'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCalendarView(allEvents),
                      _buildListView(allEvents, appState.members),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<CalendarEvent> allEvents) {
    final now = DateTime.now();
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday
    
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Month navigation
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                        _selectedDate = null;
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                        _selectedDate = null;
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Weekday headers
                Row(
                  children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                
                // Calendar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 42, // 6 weeks
                  itemBuilder: (context, index) {
                    final dayOffset = index - (startingWeekday - 1);
                    if (dayOffset < 0 || dayOffset >= daysInMonth) {
                      return const SizedBox();
                    }
                    
                    final day = dayOffset + 1;
                    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                    final eventsOnDay = _getEventsForDate(allEvents, date);
                    final isToday = date.year == now.year && 
                                   date.month == now.month && 
                                   date.day == now.day;
                    final isSelected = _selectedDate != null &&
                                      date.year == _selectedDate!.year &&
                                      date.month == _selectedDate!.month &&
                                      date.day == _selectedDate!.day;
                    
                    return GestureDetector(
                      onTap: eventsOnDay.isNotEmpty 
                          ? () => setState(() => _selectedDate = date)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? context.colors.primary
                              : isToday 
                                  ? context.colors.primary.withValues(alpha: 0.2)
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday && !isSelected
                              ? Border.all(color: context.colors.primary, width: 2)
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? context.colors.onPrimary
                                    : context.colors.onSurface,
                              ),
                            ),
                            // Event dots
                            if (eventsOnDay.isNotEmpty)
                              Positioned(
                                bottom: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: eventsOnDay.take(3).map((e) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? context.colors.onPrimary : e.color,
                                      shape: BoxShape.circle,
                                    ),
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Selected date events
          if (_selectedDate != null) ...[
            Text(
              'Événements du ${_selectedDate!.day}/${_selectedDate!.month}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ..._getEventsForDate(allEvents, _selectedDate!).map(
              (event) => _buildEventCard(event),
            ),
          ] else ...[
            // Upcoming events preview
            _buildUpcomingSection(allEvents),
          ],
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildListView(List<CalendarEvent> allEvents, List<Member> members) {
    // Separate birthdays from other events
    final birthdays = allEvents.where((e) => e.type == EventType.birthday).toList();
    final otherEvents = allEvents.where((e) => e.type != EventType.birthday).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filters (Optional: could filter both lists or just one)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', null),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Birthdays Section (Horizontal)
          if (birthdays.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '🎉 Anniversaires à venir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (birthdays.length > 3)
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160, // Fixed height for birthday cards
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: birthdays.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildBirthdayCard(birthdays[index]);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          // 2. Other Events Section (Vertical)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '📅 Calendrier & Fêtes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherEvents.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(otherEvents[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayCard(CalendarEvent event) {
    if (event.member == null) return const SizedBox();
    
    final isImminent = event.daysUntil <= 7;
    // Use a gradient based on the member's ID or name hash for variety
    final gradientKeys = AppTheme.gradients.keys.toList();
    final gradientIndex = event.member!.id.hashCode.abs() % gradientKeys.length;
    final gradient = AppTheme.getGradient(gradientKeys[gradientIndex]);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient.colors.last.a == 1.0 ? LinearGradient(
          colors: [gradient.colors.first.withValues(alpha: 0.1), gradient.colors.last.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Hero(
                tag: 'event_birthday_${event.member!.id}',
                child: MemberAvatar(member: event.member!, size: 56),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Text('🎂', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.member!.name.split(' ').first, // First name only for cleaner look
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            event.daysUntil == 0 ? "Aujourd'hui !" : 'J-${event.daysUntil}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isImminent ? context.colors.primary : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${event.member!.age + 1} ans',
            style: TextStyle(
              fontSize: 11,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? groupId) {
    final isSelected = _selectedGroupId == groupId;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: context.colors.primary.withValues(alpha: 0.3),
      backgroundColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      checkmarkColor: context.colors.primary,
      labelStyle: TextStyle(
        color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? context.colors.primary : Colors.transparent,
      ),
      onSelected: (_) => setState(() => _selectedGroupId = isSelected ? null : groupId),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    // If it's a birthday in the vertical list (e.g. filtered view or fallback), keep standard look
    // but maybe add a subtle hint. For now, standard GlassCard.
    
    final isImminent = event.daysUntil <= 7;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar or Icon
          if (event.member != null)
            MemberAvatar(member: event.member!, size: 50)
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: 0.15), // Softer background
                borderRadius: BorderRadius.circular(16), // Rounded square for events
              ),
              child: Icon(event.icon, color: event.color, size: 24),
            ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Date Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isImminent 
                      ? context.colors.primary.withValues(alpha: 0.1) 
                      : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: isImminent ? Border.all(color: context.colors.primary.withValues(alpha: 0.3)) : null,
                ),
                child: Text(
                  event.daysUntil == 0 ? "J-0" : 'J-${event.daysUntil}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isImminent ? context.colors.primary : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.date.day}/${event.date.month}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(List<CalendarEvent> allEvents) {
    final upcoming = allEvents.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔜 À venir',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...upcoming.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(event),
        )),
      ],
    );
  }
}
