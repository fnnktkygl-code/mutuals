import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

import 'timeline_screen.dart';
import 'events_screen.dart';
import 'settings_screen.dart';
import 'members_tab.dart';

import '../services/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check for updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService().checkForUpdates(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
       UpdateService().checkForUpdates(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildContent(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case 0:
        return const MembersTab(key: ValueKey('members'));
      case 1:
        return const TimelineScreen(key: ValueKey('timeline'));
      case 2:
        return const EventsScreen(key: ValueKey('events'));
      case 3:
        return const SettingsScreen(key: ValueKey('settings'));
      default:
        return const MembersTab(key: ValueKey('members'));
    }
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.spacingLg),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingLg, vertical: DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.group_outlined, Icons.group, 'Membres'),
          _buildNavItem(1, Icons.timeline_outlined, Icons.timeline, 'Envies'),
          _buildNavItem(2, Icons.cake_outlined, Icons.cake, 'Événements'),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Réglages'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        if (_currentTab != index) {
          HapticFeedback.selectionClick();
          setState(() => _currentTab = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd, vertical: DesignTokens.spacingSm),
        decoration: isSelected
            ? BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? context.colors.onPrimaryContainer : context.colors.onSurfaceVariant,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: DesignTokens.spacingSm),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
