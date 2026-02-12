import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class GroupEditorModal extends StatefulWidget {
  final String? groupId; // null for new group
  final String? initialName;
  final String? initialIcon;
  final String? initialColor;
  final Future<void> Function(String name, String icon, String color) onSave;

  const GroupEditorModal({
    super.key,
    this.groupId,
    this.initialName,
    this.initialIcon,
    this.initialColor,
    required this.onSave,
  });

  @override
  State<GroupEditorModal> createState() => _GroupEditorModalState();
}

class _GroupEditorModalState extends State<GroupEditorModal> {
  late TextEditingController _nameController;
  late String selectedIcon;
  late String selectedColor;

  // Available colors (same as avatar picker)
  static const List<Map<String, String>> availableColors = [
    {'name': 'Rouge', 'hex': '#EF4444'},
    {'name': 'Orange', 'hex': '#F97316'},
    {'name': 'Jaune', 'hex': '#EAB308'},
    {'name': 'Vert', 'hex': '#10B981'},
    {'name': 'Bleu', 'hex': '#3B82F6'},
    {'name': 'Violet', 'hex': '#8B5CF6'},
    {'name': 'Rose', 'hex': '#EC4899'},
    {'name': 'Marron', 'hex': '#92400E'},
    {'name': 'Cyan', 'hex': '#06B6D4'},
    {'name': 'Indigo', 'hex': '#6366F1'},
    {'name': 'Citron', 'hex': '#84CC16'},
    {'name': 'Gris', 'hex': '#64748B'},
    {'name': 'Aucun', 'hex': '#00000000'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    selectedIcon = widget.initialIcon ?? '⭐';
    selectedColor = widget.initialColor ?? '#6366F1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  widget.groupId == null ? 'Nouveau groupe' : 'Modifier le groupe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.colors.onSurface),
                ),
              ],
            ),
          ),

          // Sticky Section (Preview + Name + Colors)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview
                Center(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(selectedColor),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              selectedIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _nameController.text.isEmpty ? 'Nom du groupe' : _nameController.text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name Input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du groupe',
                    hintText: 'Ex: Collègues, Voisins...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Color Picker
                Text(
                  'Couleur',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableColors.map((colorData) {
                      final hexColor = colorData['hex']!;
                      final isSelected = hexColor == selectedColor;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 12), // Add bottom padding for touch target
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = hexColor;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: hexColor == '#00000000' ? Colors.white : _parseColor(hexColor),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: context.colors.onSurface, width: 3)
                                  : hexColor == '#00000000' ? Border.all(color: context.colors.outline.withValues(alpha: 0.3)) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: (hexColor == '#00000000' ? Colors.black : _parseColor(hexColor)).withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: hexColor == '#00000000' ? Colors.black : Colors.white, size: 22)
                                : hexColor == '#00000000'
                                    ? Icon(Icons.block, color: context.colors.onSurfaceVariant, size: 16)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Emoji Picker
          Expanded(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                setState(() {
                  selectedIcon = emoji.emoji;
                });
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                viewOrderConfig: const ViewOrderConfig(),
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: CategoryViewConfig(
                  initCategory: Category.SMILEYS,
                  backgroundColor: context.colors.surface,
                  indicatorColor: context.accent,
                  iconColor: context.colors.onSurfaceVariant,
                  iconColorSelected: context.accent,
                  backspaceColor: context.accent,
                ),
                bottomActionBarConfig: const BottomActionBarConfig(
                  enabled: false, // Turn off button bar since we have a dedicated search bar in the emoji picker
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: context.colors.surface,
                  buttonIconColor: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nameController.text.isEmpty
                    ? null
                    : () async {
                        await widget.onSave(
                          _nameController.text,
                          selectedIcon,
                          selectedColor,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }
}
