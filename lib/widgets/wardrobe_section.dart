import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/wardrobe_item.dart';
import '../widgets/smart_size_input.dart';
import '../theme/app_theme.dart';
import '../utils/sizing_constants.dart';

/// Wardrobe section: tops, bottoms, shoes with edit/view modes
class WardrobeSection extends StatelessWidget {
  final Member member;
  final bool isEditing;
  final ValueChanged<Member> onMemberChanged;

  const WardrobeSection({
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'GARDE-ROBE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: context.colors.outline,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCategory(
          context,
          'Hauts',
          Icons.checkroom,
          member.tops,
          (items) => onMemberChanged(member.copyWith(tops: items)),
          const Color(0xFF60A5FA), // Blue
        ),
        const SizedBox(height: 16),
        _buildCategory(
          context,
          'Bas',
          Icons.straighten,
          member.bottoms,
          (items) => onMemberChanged(member.copyWith(bottoms: items)),
          const Color(0xFF34D399), // Green
        ),
        const SizedBox(height: 16),
        _buildCategory(
          context,
          'Pieds',
          Icons.speaker_notes,
          member.shoes,
          (items) => onMemberChanged(member.copyWith(shoes: items)),
          const Color(0xFFF472B6), // Pink
        ),
      ],
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    IconData icon,
    List<WardrobeItem> items,
    Function(List<WardrobeItem>) onChanged,
    Color accentColor,
  ) {
    final headerColor = accentColor.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Colored Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: accentColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: accentColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: context.colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isEmpty && !isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aucune info',
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isShoe = title == 'Pieds';
      
                  if (isEditing) {
                    return _buildEditItem(context, title, idx, item, items, isShoe, onChanged);
                  }
                  return _buildViewItem(context, item, accentColor);
                }),
                if (isEditing) ...[
                  if (items.isNotEmpty) const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      final newItems = List<WardrobeItem>.from(items);
                      newItems.add(WardrobeItem(type: '', size: ''));
                      onChanged(newItems);
                    },
                    icon: const Icon(Icons.add_circle, size: 16),
                    label: const Text('Ajouter un élément'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditItem(
    BuildContext context,
    String title,
    int idx,
    WardrobeItem item,
    List<WardrobeItem> items,
    bool isShoe,
    Function(List<WardrobeItem>) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Add Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _getQuickSuggestions(title).map((suggestion) {
                          final isSelected = item.type == suggestion;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(suggestion),
                              onPressed: () {
                                final newItems = List<WardrobeItem>.from(items);
                                newItems[idx] = item.copyWith(type: suggestion);
                                onChanged(newItems);
                              },
                              visualDensity: VisualDensity.standard, // Larger touch target
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              labelStyle: TextStyle(
                                fontSize: 15, // Increased from 13
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? context.colors.onPrimary : context.colors.onSurface,
                              ),
                              backgroundColor: isSelected 
                                  ? context.colors.primary 
                                  : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                              side: isSelected ? BorderSide.none : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide.none,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: ValueKey('wardrobe_type_$idx'),
                      initialValue: item.type,
                      onChanged: (value) {
                        final newItems = List<WardrobeItem>.from(items);
                        newItems[idx] = item.copyWith(type: value);
                        onChanged(newItems);
                      },
                      style: TextStyle(color: context.colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Type (ou choisir ci-dessus)',
                        hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final newItems = List<WardrobeItem>.from(items);
                  newItems.removeAt(idx);
                  onChanged(newItems);
                },
                icon: const Icon(Icons.close, size: 20),
                color: context.colors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SmartSizeInput(
            label: 'Taille',
            value: item.size,
            isShoe: isShoe,
            onChanged: (value) {
              final newItems = List<WardrobeItem>.from(items);
              newItems[idx] = item.copyWith(size: value);
              onChanged(newItems);
            },
          ),
          const SizedBox(height: 12),
          // Size Note
          TextFormField(
            key: ValueKey('wardrobe_note_$idx'),
            initialValue: item.sizeNote,
            onChanged: (value) {
              final newItems = List<WardrobeItem>.from(items);
              newItems[idx] = item.copyWith(sizeNote: value);
              onChanged(newItems);
            },
            style: TextStyle(color: context.colors.onSurface, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Note de taille',
              hintText: 'Ex: Préfère S pour les vestes',
              hintStyle: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
              labelStyle: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          // Waist/Length for bottoms
          if (title == 'Bas') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('wardrobe_waist_$idx'),
                    initialValue: item.waist?.isEmpty ?? true ? null : item.waist,
                    decoration: InputDecoration(
                      labelText: 'Tour de taille (W)',
                      labelStyle: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    items: SizingConstants.waistSizes.map((w) {
                      return DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (value) {
                      final newItems = List<WardrobeItem>.from(items);
                      newItems[idx] = item.copyWith(waist: value ?? '');
                      onChanged(newItems);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('wardrobe_length_$idx'),
                    initialValue: item.length?.isEmpty ?? true ? null : item.length,
                    decoration: InputDecoration(
                      labelText: 'Longueur (L)',
                      labelStyle: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    items: SizingConstants.lengthSizes.map((l) {
                      return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (value) {
                      final newItems = List<WardrobeItem>.from(items);
                      newItems[idx] = item.copyWith(length: value ?? '');
                      onChanged(newItems);
                    },
                  ),
                ),
              ],
            ),
          ],
          // Shoe size in cm
          if (isShoe) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('wardrobe_shoe_cm_$idx'),
              initialValue: item.shoeSizeCm?.isEmpty ?? true ? null : item.shoeSizeCm,
              decoration: InputDecoration(
                labelText: 'Pointure en cm',
                labelStyle: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              items: SizingConstants.shoeSizesCm.map((cm) {
                return DropdownMenuItem(value: cm, child: Text('$cm cm', style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (value) {
                final newItems = List<WardrobeItem>.from(items);
                newItems[idx] = item.copyWith(shoeSizeCm: value ?? '');
                onChanged(newItems);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewItem(BuildContext context, WardrobeItem item, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                // Highlighted Size Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item.size,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            if (item.sizeNote.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.sizeNote,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (item.waist != null || item.length != null) ...[
              const SizedBox(height: 6),
              Text(
                'W${item.waist ?? '?'} L${item.length ?? '?'}',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            if (item.shoeSizeCm != null && item.shoeSizeCm!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${item.shoeSizeCm} cm',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _getQuickSuggestions(String title) {
    switch (title) {
      case 'Hauts':
        return ['T-shirt', 'Pull', 'Sweat', 'Chemise', 'Veste', 'Manteau'];
      case 'Bas':
        return ['Jean', 'Pantalon', 'Short', 'Jupe', 'Legging', 'Jogging'];
      case 'Pieds':
        return ['Sneakers', 'Bottes', 'Sandales', 'Mocassins', 'Talons'];
      default:
        return [];
    }
  }
}
