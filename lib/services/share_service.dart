import 'package:share_plus/share_plus.dart';
import '../models/member.dart';
import '../utils/date_utils.dart' as date_utils;

class ShareService {
  /// Share member summary via WhatsApp or other apps
  static Future<void> shareMemberSummary(List<Member> members) async {
    final currentMonthKey = date_utils.DateUtils.getCurrentMonthKey();
    
    final summary = members.map((member) {
      final currentWish = member.wishHistory
          .where((w) => w.monthKey == currentMonthKey)
          .firstOrNull;
      
      final shoeSizeText = member.shoes.isNotEmpty 
          ? member.shoes.first.size 
          : '?';
      final topSizeText = member.tops.isNotEmpty 
          ? member.tops.first.size 
          : '?';
      
      return '👤 ${member.name} (${member.relationship.isEmpty ? 'Moi' : member.relationship})\n'
          '👟 $shoeSizeText | 👕 $topSizeText\n'
          '✨ Envie : ${currentWish?.text ?? 'Rien'}';
    }).join('\n\n');
    
    final fullText = 'Voici les tailles et envies de la famille :\n\n$summary';
    
    await Share.share(fullText, subject: 'Famille.io - Récap');
  }
}
