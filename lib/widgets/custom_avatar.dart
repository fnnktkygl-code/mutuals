import 'package:flutter/material.dart';

/// Displays a custom avatar with a character image and customizable background color
class CustomAvatar extends StatelessWidget {
  final String characterId; // e.g., "avatar_42"
  final String backgroundColor; // Hex color like "#6366F1"
  final double size;

  const CustomAvatar({
    super.key,
    required this.characterId,
    required this.backgroundColor,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Parse hex color
    Color bgColor = _parseColor(backgroundColor);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildAvatarContent(context, bgColor),
    );
  }

  Widget _buildAvatarContent(BuildContext context, Color bgColor) {
    if (characterId.startsWith('default_')) {
      // If background is transparent, tint the image to match the text color (dynamic for light/dark mode)
      // If background is colored, tint white if the background is dark, otherwise keep original black
      final isTransparent = bgColor.a == 0;
      final isDarkBg = !isTransparent && bgColor.computeLuminance() < 0.5;
      
      return ClipOval(
        child: Image.asset(
          'assets/avatars/defaults/$characterId.png',
          fit: BoxFit.cover,
          color: isTransparent 
              ? Theme.of(context).colorScheme.onSurface 
              : (isDarkBg ? Colors.white.withValues(alpha: 0.9) : null),
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.person,
                size: size * 0.6,
                color: isTransparent 
                    ? Theme.of(context).colorScheme.onSurface 
                    : (isDarkBg ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.6)),
              ),
            );
          },
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        'assets/avatars/$characterId.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }


  Color _parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not present
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1); // Default purple
    }
  }
}
