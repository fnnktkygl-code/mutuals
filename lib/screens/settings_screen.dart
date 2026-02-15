import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/update_service.dart';

import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // Theme Mode Section
            _buildSectionTitle(context, '🎨 Apparence'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thème',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppThemeMode.values.map((mode) {
                      final isSelected = appState.themeMode == mode;
                      return _buildThemeModeChip(
                        context,
                        mode: mode,
                        isSelected: isSelected,
                        onTap: () => appState.setThemeMode(mode),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Accent Color Section
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Couleur d\'accent',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AccentColor.values.map((color) {
                      final isSelected = appState.accentColor == color;
                      return _buildAccentColorSwatch(
                        context,
                        color: color,
                        isSelected: isSelected,
                        onTap: () => appState.setAccentColor(color),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Notifications Section
            _buildSectionTitle(context, '🔔 Notifications'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              onTap: () => appState.toggleNotifications(!appState.notificationsEnabled),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: appState.notificationsEnabled 
                          ? context.accent 
                          : context.textTertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Rappels anniversaires',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  const Spacer(),
                  _buildSwitch(
                    context,
                    value: appState.notificationsEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Filou Account Prompt
            _buildSectionTitle(context, '🐼 Sécurité'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.semantic.mascotSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🐼', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sauvegarde ton compte !',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.semantic.mascot,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Connecte Google ou Apple pour ne rien perdre.',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: context.textTertiary),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About Section
            _buildSectionTitle(context, 'ℹ️ À propos'),
            const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.system_update, color: context.colors.primary),
                      ),
                      title: Text('Vérifier les mises à jour', style: TextStyle(fontWeight: FontWeight.w600, color: context.textColor)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: context.textTertiary),
                      onTap: () => UpdateService().checkForUpdates(context, manualTrigger: true),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.help_outline, color: context.colors.primary),
                      ),
                      title: const Text('Revoir les tutoriels', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: context.textTertiary),
                      onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Revoir les tutoriels'),
                    content: const Text('Voulez-vous réinitialiser les aides visuelles pour toutes les pages ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
                    ],
                  ),
                );
                
                if (confirm == true) {
                   await StorageService.resetTutorials();
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Tutoriels réinitialisés !')),
                     );
                   }
                }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Danger Zone
            Divider(color: context.borderColor),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => _showResetDialog(context, appState),
                child: Text(
                  'Réinitialiser l\'application (Local)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, appState),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                  backgroundColor: context.colors.error.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever, size: 16, color: context.colors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Supprimer mon compte',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Mutuals v1.0 — Made with 🐼 by Filou',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ...

  Future<void> _showDeleteAccountDialog(BuildContext context, AppState appState) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
            '⚠️ Attention : Cette action est irréversible.\n\n'
            '• Vous serez retiré de tous les espaces partagés.\n'
            '• Vos espaces créés seront supprimés.\n'
            '• Vos données personnelles seront effacées.\n\n'
            'Voulez-vous vraiment continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Second confirmation? Maybe not needed for now, but safer.
      // Let's just proceed.
      try {
        await appState.deleteAccount();
        if (context.mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Compte supprimé avec succès.')),
           );
        }
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Erreur: $e')),
           );
        }
      }
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: context.textColor,
      ),
    );
  }

  Widget _buildThemeModeChip(
    BuildContext context, {
    required AppThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.accent : context.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.accent : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '${mode.icon} ${mode.label}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : context.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorSwatch(
    BuildContext context, {
    required AccentColor color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? context.textColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildSwitch(BuildContext context, {required bool value}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: value ? context.accent : context.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value ? Colors.white : context.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, AppState appState) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser l\'application'),
        content: const Text(
            'Voulez-vous vraiment effacer toutes les données et recommencer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AccentColor.red.color,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await appState.resetApp();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    }
  }

}
