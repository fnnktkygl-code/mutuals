import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/share_service.dart';
import 'package:share_plus/share_plus.dart';
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
             const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: context.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Revoir les tutoriels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.refresh,
                    color: context.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
            // Share Section
            _buildSectionTitle(context, '📤 Partage'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              onTap: () async {
                await ShareService.shareMemberSummary(appState.members);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    color: context.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Partager le récap (WhatsApp)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Data Management Section
            _buildSectionTitle(context, '💾 Données'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Export
                  InkWell(
                    onTap: () async {
                      final json = appState.exportData();
                      await Share.share(json, subject: 'Famille.io Config');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.upload_file, color: context.accent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Exporter la configuration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                              ),
                            ),
                          ),
                          Icon(Icons.ios_share, color: context.textTertiary, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  // Import
                  InkWell(
                    onTap: () => _showImportDialog(context, appState),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.download_for_offline, color: context.accent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Importer une configuration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: context.textTertiary, size: 16),
                        ],
                      ),
                    ),
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
                  'Réinitialiser l\'application',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AccentColor.red.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Famille.io v4.0 (Theme System)',
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
  Future<void> _showImportDialog(BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer une configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Collez le code de configuration (JSON) ci-dessous. \n⚠️ Ceci remplacera vos données actuelles.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Collez le code ici...',
                border: OutlineInputBorder(),
                filled: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final json = controller.text.trim();
                if (json.isEmpty) return;
                
                Navigator.pop(context); // Close dialog
                
                await appState.importData(json);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Importation réussie !')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Erreur: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }
}
