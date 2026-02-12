import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pre-defined tag suggestions for quick selection
const List<String> suggestedTags = [
  '🎮 Gamer',
  '👨‍🍳 Chef',
  '📚 Lecteur',
  '🎵 Musicien',
  '⚽ Sportif',
  '🎨 Artiste',
  '🌱 Jardinier',
  '✈️ Voyageur',
  '🎬 Cinéphile',
  '🧘 Bien-être',
  '💻 Tech',
  '🏠 Déco',
  '👗 Mode',
  '🍷 Oenophile',
  '📷 Photo',
];

/// Gift category suggestions based on tags
const Map<String, List<String>> tagToGiftCategories = {
  '🎮 Gamer': ['Jeux vidéo', 'Accessoires gaming', 'Abonnement gaming'],
  '👨‍🍳 Chef': ['Ustensiles cuisine', 'Livres de recettes', 'Épices rares'],
  '📚 Lecteur': ['Livres', 'Liseuse', 'Abonnement bibliothèque'],
  '🎵 Musicien': ['Instruments', 'Vinyles', 'Concert tickets'],
  '⚽ Sportif': ['Équipement sportif', 'Vêtements sport', 'Montres fitness'],
  '🎨 Artiste': ['Matériel art', 'Cours créatifs', 'Expo/musée'],
  '🌱 Jardinier': ['Plantes', 'Outils jardin', 'Graines rares'],
  '✈️ Voyageur': ['Bagages', 'Accessoires voyage', 'Guides de voyage'],
  '🎬 Cinéphile': ['Blu-ray/DVD', 'Abonnement streaming', 'Posters'],
  '🧘 Bien-être': ['Spa/massage', 'Yoga mat', 'Aromathérapie'],
  '💻 Tech': ['Gadgets', 'Accessoires tech', 'Formations en ligne'],
  '🏠 Déco': ['Objets déco', 'Bougies parfumées', 'Art mural'],
  '👗 Mode': ['Vêtements', 'Accessoires', 'Cartes cadeaux mode'],
  '🍷 Oenophile': ['Vins', 'Accessoires vin', 'Cours dégustation'],
  '📷 Photo': ['Accessoires photo', 'Tirages/albums', 'Cours photo'],
};

/// Widget for editing member tags
class TagEditor extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;

  const TagEditor({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  late List<String> _tags;
  final TextEditingController _customTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
    widget.onChanged(_tags);
  }

  void _addCustomTag() {
    final text = _customTagController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
      });
      _customTagController.clear();
      widget.onChanged(_tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '🏷️ Tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
        ),
        
        // Suggested tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              selectedColor: context.accent.withValues(alpha: 0.3),
              backgroundColor: isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              checkmarkColor: context.accent,
              labelStyle: TextStyle(
                color: isSelected
                    ? context.accent
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? context.accent 
                    : Colors.transparent,
              ),
              onSelected: (_) => _toggleTag(tag),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Custom tag input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customTagController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un tag personnalisé...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onSubmitted: (_) => _addCustomTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addCustomTag,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.accent, const Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        
        // Current custom tags (not in suggested list)
        if (_tags.any((t) => !suggestedTags.contains(t))) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .where((t) => !suggestedTags.contains(t))
                .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _toggleTag(tag),
                      backgroundColor: context.accent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white : context.accent,
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }
}

/// Utility to get gift suggestions based on member tags
List<String> getGiftSuggestions(List<String> tags) {
  final suggestions = <String>{};
  for (final tag in tags) {
    final categories = tagToGiftCategories[tag];
    if (categories != null) {
      suggestions.addAll(categories);
    }
  }
  return suggestions.toList();
}
