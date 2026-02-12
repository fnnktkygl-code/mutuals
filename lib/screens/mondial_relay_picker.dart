import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

class MondialRelayPicker extends StatefulWidget {
  const MondialRelayPicker({super.key});

  @override
  State<MondialRelayPicker> createState() => _MondialRelayPickerState();
}

class _MondialRelayPickerState extends State<MondialRelayPicker> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'ParcelShopPickerChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            Navigator.pop(context, data);
          } catch (e) {
            debugPrint('Error parsing Mondial Relay data: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erreur lors de la sélection du point relais')),
            );
          }
        },
      )
      ..loadFlutterAsset('assets/html/mondial_relay_widget.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un Point Relais'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        elevation: 0,
        actions: [
          // Debug bypass for when Mondial Relay Test Env is down
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Simuler un point (Debug)',
            onPressed: () {
              Navigator.pop(context, {
                'ID': '99999',
                'Name': 'Relais Test Debug',
                'Address1': '1 Place de la Comédie',
                'ZipCode': '34000',
                'City': 'Montpellier',
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: context.colors.surface,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
