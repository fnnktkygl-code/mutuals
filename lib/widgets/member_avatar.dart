import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../utils/file_image_provider.dart';

class MemberAvatar extends StatelessWidget {
  final Member member;
  final double size;
  final bool showBorder;

  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 56,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Custom avatar with character + background color
    if (member.avatarType == 'custom' && member.avatarCharacterId != null) {
      return _buildCustomAvatar(context);
    } else if (member.avatarType == 'image' && member.avatarValue.isNotEmpty) {
      return _buildImageAvatar(context);
    } else if (member.avatarType == 'emoji') {
       return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.white,
          shape: BoxShape.circle,
          border: showBorder ? Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: size * 0.04,
          ) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: size * 0.2,
              offset: Offset(0, size * 0.1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            member.avatarValue.isEmpty ? '👤' : member.avatarValue,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      );
    } else {
      // Gradient fallback
      return _buildGradientAvatar();
    }
  }

  Widget _buildGradientAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.getGradient(member.gradient),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.getGradient(member.gradient)
                .colors
                .first
                .withValues(alpha: 0.4),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
        border: showBorder ? Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: size * 0.04,
        ) : null,
      ),
      child: Center(
        child: Text(
          member.name.isNotEmpty 
              ? member.name.substring(0, member.name.length >= 2 ? 2 : member.name.length).toUpperCase() 
              : '?',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImageAvatar(BuildContext context) {
    // On web, File-based images are not supported; fall back to gradient
    if (kIsWeb) {
      return _buildGradientAvatar();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: createFileImageProvider(member.avatarValue),
          fit: BoxFit.cover,
        ),
        border: showBorder ? Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: size * 0.04,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAvatar(BuildContext context) {
    final bgColor = _parseColor(member.avatarBackgroundColor ?? '#6366F1');
    
    // Tinting logic for default avatars (silhouettes)
    Color? color;
    if (member.avatarCharacterId != null && member.avatarCharacterId!.startsWith('default_')) {
       final isTransparent = bgColor.a == 0;
       final isDarkBg = !isTransparent && bgColor.computeLuminance() < 0.5;
       if (isTransparent) {
         color = Theme.of(context).colorScheme.onSurface;
       } else if (isDarkBg) {
         color = Colors.white.withValues(alpha: 0.9);
       }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: size * 0.04,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          member.avatarCharacterId != null && member.avatarCharacterId!.startsWith('default_') 
              ? 'assets/avatars/defaults/${member.avatarCharacterId}.png'
              : 'assets/avatars/${member.avatarCharacterId}.png',
          fit: BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.white.withValues(alpha: 0.8),
            );
          },
        ),
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
