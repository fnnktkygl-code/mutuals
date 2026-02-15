/// Filou mascot states — each maps to a PNG asset.
enum FilouState {
  happy,
  waving,
  confused,
  gift,
  celebrating,
  measuring,
  phone,
  worried;

  /// Path to the mascot PNG for this state.
  String get assetPath => 'assets/mascott/$_filename';

  /// Fallback emoji if the image fails to load.
  String get fallbackEmoji {
    switch (this) {
      case FilouState.happy:
        return '🐼';
      case FilouState.waving:
        return '👋';
      case FilouState.confused:
        return '🔍';
      case FilouState.gift:
        return '🎁';
      case FilouState.celebrating:
        return '🎉';
      case FilouState.measuring:
        return '📏';
      case FilouState.phone:
        return '📱';
      case FilouState.worried:
        return '⚠️';
    }
  }

  String get _filename {
    switch (this) {
      case FilouState.happy:
        return 'standard_neutre-removebg-preview.png';
      case FilouState.waving:
        return 'accueil_welcome-removebg-preview.png';
      case FilouState.confused:
        return 'enquete_empty_state_1-removebg-preview.png';
      case FilouState.gift:
        return 'genereux_empty_state_2-removebg-preview.png';
      case FilouState.celebrating:
        return 'celebrant_success-removebg-preview.png';
      case FilouState.measuring:
        return 'expert_taille_feature_core-removebg-preview.png';
      case FilouState.phone:
        return 'connecte_sync-removebg-preview.png';
      case FilouState.worried:
        return 'protecteur_alert-removebg-preview.png';
    }
  }
}
