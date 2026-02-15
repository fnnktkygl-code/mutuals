import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String _versionUrl = 'https://fnnktkygl-code.github.io/mutuals/version.json';

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      final response = await http.get(Uri.parse(_versionUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final remoteBuildNumber = data['buildNumber'] as int?;
        final downloadUrl = data['downloadUrl'] as String?;
        final releaseNotes = data['releaseNotes'] as String?;

        if (remoteBuildNumber != null && remoteBuildNumber > currentBuildNumber) {
          if (context.mounted) {
            _showUpdateDialog(context, downloadUrl ?? '', releaseNotes);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog(BuildContext context, String url, String? notes) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Mise à jour disponible 🚀'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Une nouvelle version de Mutuals est disponible.'),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Nouveautés :', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _launchUrl(url);
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}
