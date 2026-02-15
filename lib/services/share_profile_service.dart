import 'package:share_plus/share_plus.dart';
import '../models/member.dart';

/// Share modes for profile sharing
enum ShareMode {
  full,       // All information
  restricted, // Basic info only (no sizes or personal details)
}

/// Service for generating and sharing member profiles
class ShareProfileService {
  /// Generate shareable text for a member profile
  static String generateShareText(Member member, ShareMode mode) {
    final buffer = StringBuffer();
    
    buffer.writeln('👤 ${member.name}');
    if (member.relationship.isNotEmpty) {
      buffer.writeln('   ${member.relationship}');
    }
    buffer.writeln();
    
    if (mode == ShareMode.full) {
      // Full share includes all details
      
      // Birthday & Age
      if (member.birthday != null) {
        final months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 
                        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
        buffer.writeln('🎂 ${member.birthday!.day} ${months[member.birthday!.month]}');
        if (member.age > 0) {
          buffer.writeln('   ${member.age} ans');
        }
        buffer.writeln();
      }
      
      // General sizes
      if (member.generalTopSize.isNotEmpty || 
          member.generalBottomSize.isNotEmpty || 
          member.generalShoeSize.isNotEmpty) {
        buffer.writeln('📏 Tailles:');
        if (member.generalTopSize.isNotEmpty) {
          buffer.writeln('   • Haut: ${member.generalTopSize}');
        }
        if (member.generalBottomSize.isNotEmpty) {
          buffer.writeln('   • Bas: ${member.generalBottomSize}');
        }
        if (member.generalShoeSize.isNotEmpty) {
          buffer.writeln('   • Chaussures: ${member.generalShoeSize}');
        }
        buffer.writeln();
      }
      
      // Fit preference
      buffer.writeln('👕 Coupe préférée: ${_fitPreferenceLabel(member.fitPreference)}');
      buffer.writeln();
      
      // Brands
      if (member.topBrands.isNotEmpty) {
        buffer.writeln('🏷️ Marques préférées:');
        buffer.writeln('   ${member.topBrands}');
        buffer.writeln();
      }
      
      // Tags
      if (member.tags.isNotEmpty) {
        buffer.writeln('🏷️ Tags: ${member.tags.join(', ')}');
        buffer.writeln();
      }
      
      // Wishlist
      if (member.wishlist.isNotEmpty) {
        buffer.writeln('🎁 Liste d\'envies:');
        for (final wish in member.wishlist) {
          buffer.writeln('   • $wish');
        }
        buffer.writeln();
      }
      
      // Current wish
      final currentWish = member.wishHistory.isNotEmpty 
          ? member.wishHistory.first 
          : null;
      if (currentWish != null) {
        buffer.writeln('💭 Envie du moment: ${currentWish.text}');
        buffer.writeln();
      }
    } else {
      // Restricted share - basic info only
      buffer.writeln('📌 Profil partagé en mode restreint');
      buffer.writeln();
      
      if (member.tags.isNotEmpty) {
        buffer.writeln('🏷️ Centres d\'intérêt: ${member.tags.join(', ')}');
        buffer.writeln();
      }
    }
    
    buffer.writeln('---');
    buffer.writeln('Partagé via Mutuals 👨‍👩‍👧‍👦');
    
    return buffer.toString();
  }
  
  /// Share a member profile
  static Future<void> shareProfile(Member member, ShareMode mode) async {
    final text = generateShareText(member, mode);
    await Share.share(
      text,
      subject: 'Profil de ${member.name} - Mutuals',
    );
  }
  
  static String _fitPreferenceLabel(dynamic fitPreference) {
    final value = fitPreference.toString().split('.').last;
    switch (value) {
      case 'slim':
        return 'Près du corps';
      case 'regular':
        return 'Normal';
      case 'oversize':
        return 'Oversize (prendre une taille au-dessus)';
      default:
        return 'Normal';
    }
  }
}
