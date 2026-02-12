import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_avatar.dart';

class AvatarPickerModal extends StatefulWidget {
  final String? initialCharacterId;
  final String? initialBackgroundColor;
  final Function(String characterId, String backgroundColor) onConfirm;

  const AvatarPickerModal({
    super.key,
    this.initialCharacterId,
    this.initialBackgroundColor,
    required this.onConfirm,
  });

  @override
  State<AvatarPickerModal> createState() => _AvatarPickerModalState();
}

class _AvatarPickerModalState extends State<AvatarPickerModal> {
  late String selectedCharacterId;
  late String selectedBackgroundColor;

  // Available background colors (app's accent colors)
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

  // TODO: This should be dynamically generated based on available avatar assets
  // Using DiceBear assets + user provided
  static const int totalAvatars = 38; // Increased to 38 available assets

  @override
  void initState() {
    super.initState();
    selectedCharacterId = widget.initialCharacterId ?? 'avatar_1';
    selectedBackgroundColor = widget.initialBackgroundColor ?? '#6366F1';
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  'Choisir un avatar',
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

          // Sticky Preview & Color Palette
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.1), // Slightly stronger shadow
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Preview
                Center(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16), // Reduced padding
                    child: CustomAvatar(
                      characterId: selectedCharacterId,
                      backgroundColor: selectedBackgroundColor,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Color Palette (Horizontal Scroll)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Couleur de fond',
                        style: TextStyle(
                          fontSize: 14, // Slightly smaller label
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildColorPalette(),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Default Avatars Section
                  Text(
                    'Silhouettes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDefaultAvatarGrid(),
                  const SizedBox(height: 32),

                  // Character Grid Section
                  Text(
                    'Personnages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCharacterGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(selectedCharacterId, selectedBackgroundColor);
                  Navigator.pop(context);
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
                  'Confirmer',
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

  Widget _buildColorPalette() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: availableColors.map((colorData) {
          final hexColor = colorData['hex']!;
          final isSelected = hexColor == selectedBackgroundColor;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBackgroundColor = hexColor;
                });
              },
              child: Container(
                width: 48, // Slightly smaller for horizontal list
                height: 48,
                decoration: BoxDecoration(
                  color: hexColor == '#00000000' ? Colors.white : _parseColor(hexColor),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: context.colors.onSurface, width: 3)
                      : hexColor == '#00000000' ? Border.all(color: context.colors.outline.withValues(alpha: 0.3)) : null,
                  boxShadow: [
                    BoxShadow(
                      color: (hexColor == '#00000000' ? Colors.black : _parseColor(hexColor)).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: hexColor == '#00000000' ? Colors.black : Colors.white,
                        size: 24,
                      )
                    : hexColor == '#00000000'
                        ? Icon(Icons.block, color: context.colors.onSurfaceVariant, size: 20)
                        : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultAvatarGrid() {
    final defaultAvatars = [
      'default_man', 'default_woman',
      'default_boy', 'default_girl',
      'default_elder_man', 'default_elder_woman',
      'default_hijabie',
      'default_man_dreads', 'default_woman_dreads',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: defaultAvatars.map((characterId) {
        final isSelected = characterId == selectedCharacterId;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCharacterId = characterId;
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: context.accent, width: 3)
                  : Border.all(
                      color: context.colors.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
            ),
            child: ClipOval(
            child: Image.asset(
              'assets/avatars/defaults/$characterId.png',
              fit: BoxFit.cover,
              color: context.colors.onSurface, // Always adapt to theme in the picker grid
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: isSelected ? context.accent : context.colors.onSurfaceVariant,
                    size: 30,
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCharacterGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: totalAvatars,
      itemBuilder: (context, index) {
        final characterId = 'avatar_${index + 1}';
        final isSelected = characterId == selectedCharacterId;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCharacterId = characterId;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: context.accent, width: 3)
                  : Border.all(
                      color: context.colors.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/avatars/$characterId.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder for missing avatars
                  return Container(
                    color: context.colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
                      size: 24,
                      color: context.colors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
